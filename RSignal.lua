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



function RSignalClass.new(identifier: string): Signal<callback<any>> & _classSignal

	local self : Signal<callback<any>> & _classSignal = {}
	self.FireConditions = {} :: {
		[any]: boolean,
	}
	self.success = false
	self.tryManager = {}
	self._connections = {}
	self.catchManager = {}
	
	local _success = nil
	
	local Event = Instance.new("BindableEvent")



	function self:Connect(callback: callback<any>)
		local conn
		
		local s, _ = task.spawn(pcall, function()
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
