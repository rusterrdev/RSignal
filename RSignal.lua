local RSignalClass = {}

export type Connection<Callback> = {
	Disconnect : (self: {}) -> (),

}

export type callback<rType> = (...any) -> (rType, ...any)

export type Signal<callbacktype> = {

	clearConnections: () -> (),

}

export type tryFire = {
	try: (condition: boolean) -> _catch,
}

export type _catch = {
	catch: (self: {}, callback: callback<any>) -> (),
}

export type _classSignal = {
	Fire: (self: {}, ...any) -> tryFire,
	Connect: (self: {}, Callback: callback<any>) -> Connection<callback<any>>,
	Wait: (self: {}) -> (),
}

local ReplicatedStorage = game.ReplicatedStorage

local _events_folder: Folder =
	if ReplicatedStorage:FindFirstChild('_Rsignal_events') then
	ReplicatedStorage._Rsignal_events
	else
	Instance.new("Folder", ReplicatedStorage)

_events_folder.Name = '_Rsignal_events'


function RSignalClass.new(identifier: string): Signal<callback<any>> & _classSignal

	local self : Signal<callback<any>> & _classSignal = {}
	self.FireConditions = {} :: {
		[any]: boolean,
	}
	self.success = false
	self.tryManager = {}
	self._connections = {}
	self.catchManager = {}

	local function getEventByIdentifier()

		local event = nil
		
		if not _events_folder:FindFirstChild(identifier) then 
			event = Instance.new('BindableEvent', _events_folder)
			return event
		end
		
		return _events_folder[identifier]
		
	end

	local _success = nil

	local Event: BindableEvent = if getEventByIdentifier() ~= nil then
		getEventByIdentifier()
		else
		Instance.new("BindableEvent", _events_folder)
	Event.Name = identifier
	
	
	
	function self:Connect(callback: callback<any>)
		local conn
		
		local s, _ = task.spawn(function()
			
			conn = Event.Event:Connect(callback)
			
		end)

		if s then

			local connection: Connection<callback<any>> = {
				Callback = callback,
				Disconnect = function()
					conn:Disconnect()
				end,
			}

			table.insert(self._connections, connection)
		else
			print('erro')
		end
	end

	function self.tryManager.try(condition: boolean): boolean
		local success = 
			if condition then
			true
			else
			false

		table.insert(self.FireConditions, success)
		_success = success

		return self.catchManager
	end

	function self.catchManager:catch(callback: callback<any>) 

		while _success == nil do end

		task.defer(function()
			if not _success then

				callback()

			end
		end)

	end

	function self._try(...)
		for _, condition in self.FireConditions do
			if not condition then return end
		end
		Event:Fire(...)
	end



	function self:Fire(...)


		task.defer(self._try, ...)

		return self.tryManager
	end

	function self:Wait()

		Event.Event:Wait()

	end


	return self
end



return RSignalClass
