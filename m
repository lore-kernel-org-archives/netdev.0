From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Ethernet bridge performance
Date: Mon, 11 Aug 2003 09:52:40 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16183.19272.107650.647577@robur.slu.se>
References: <3F3217E7.2080903@allot.com>
	<3F3284EA.5050406@candelatech.com>
	<3F328A0F.3040005@allot.com>
	<16178.41976.3643.584516@robur.slu.se>
	<1060284094.1024.36.camel@jzny.localdomain>
	<3F35F51B.7080301@allot.com>
	<1060570537.1050.17.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Felix Radensky <felix@allot.com>,
   Robert Olsson <Robert.Olsson@data.slu.se>,
   Ben Greear <greearb@candelatech.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1060570537.1050.17.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


jamal writes:
 > 
 > Felix,
 > 
 > Actually i based my comments on the profiles you posted ;->
 > Are you running any other nics? If not that profile does look strange.


 Yes netif_rx the non-NAPI entrance to the upper layers is in the profiles.

 c019ad44 3404      5.3328     netif_rx


 Cheers.
						--ro
