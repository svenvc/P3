baseline
baselineOf: spec
	<baseline>
	spec for: #common do: [ 
		spec configuration: 'NeoJSON' with: [
			spec 
				versionString: #stable;
				repository: 'http://mc.stfx.eu/Neo' ]. 
		spec configuration: 'ZTimestamp' with: [
			spec 
				versionString: #stable;
				repository: 'http://mc.stfx.eu/Neo' ]. 
		spec configuration: 'Glorp' with: [
			spec 
				versionString: #stable;
				repository: 'http://www.smalltalkhub.com/mc/DBXTalk/Configurations/main' ].
		spec package: 'P3' with: [ spec requires: #('NeoJSON' 'ZTimestamp') ].
		spec package: 'P3-Glorp' with: [ spec requires: #('P3' 'Glorp') ].
		spec group: 'default' with: #('P3').
		spec group: 'glorp' with: #('P3-Glorp') ]