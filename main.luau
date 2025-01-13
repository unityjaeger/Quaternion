--!native

local Quaternion = {}

local toAxisAngle = CFrame.identity.ToAxisAngle

local function normalize(w: number, v: Vector3): (number, Vector3)
	local magnitude = (w * w + v.X * v.X + v.Y * v.Y + v.Z * v.Z) ^ .5
	if magnitude == 0 then
		return 0, Vector3.zero --avoid NaN
	end
	return w / magnitude, v / magnitude
end

function Quaternion.fromCFrame(cframe: CFrame): (number, Vector3)
	local axis, angle = cframe:ToAxisAngle()
	local halfAngle = angle / 2
	return math.cos(halfAngle), math.sin(halfAngle) * axis
end

function Quaternion.toCFrameSafe(w: number, v: Vector3): CFrame
	local axis = vector.normalize(v)
	local angle = 2 * math.acos(w)
	return CFrame.fromAxisAngle(axis, angle)
end

function Quaternion.toCFrame(w: number, v: Vector3): CFrame
	local angle = 2 * math.acos(w)
	return CFrame.fromAxisAngle(v.Unit, angle)
end

function Quaternion.slerp(w0: number, v0: Vector3, w1: number, v1: Vector3, alpha: number): (number, Vector3)
	local dot = v0.X * v1.X + v0.Y * v1.Y + v0.Z * v1.Z + w0 * w1
	if dot < 0 then
		w0 = -w0
		v0 = -v0
		dot = -dot
	end
	
	if dot >= 1 then
		local subw, subv = w1 - w0, v1 - v0
		return normalize(w0 + subw * alpha, v0 + subv * alpha)
	end
	
	local theta0 = math.acos(dot)
	local sinTheta0 = math.sin(theta0)
	
	local theta = theta0 * alpha
	local sinTheta = math.sin(theta)
	
	local s1 = sinTheta / sinTheta0
	local s0 = math.cos(theta) - dot * s1
	
	local w = s0 * w0 + s1 * w1
	local v = s0 * v0 + s1 * v1
	
	return normalize(w, v)
end

--[[
input format: {w0, v0, w1, v1, ...}
prerequisites: all input quaternions must be weighted and normalized, total weight must add up to 1
]]
function Quaternion.average(array: {number & Vector3}): (number, Vector3)
	local sumw, sumv = 0, Vector3.zero
	local size = #array
	
	for i = 1, size, 2 do
		sumw += array[i]
		sumv += array[i + 1]
	end
	
	local trials = size / 2
	return sumw / trials, sumv / trials
end

return Quaternion
