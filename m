From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: strange e1000 interface freeze
Date: Wed, 11 Aug 2004 17:08:53 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16666.13957.266124.967306@robur.slu.se>
References: <411757CA.4010401@draigBrady.com>
	<16666.11408.446131.763707@robur.slu.se>
	<411A3238.6060400@draigBrady.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        e1000-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: P@draigBrady.com
In-Reply-To: <411A3238.6060400@draigBrady.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


P@draigBrady.com writes:

 > Interesting.
 > We've noticed the problems on 133MHz but not on 100MHz
 > We're double checking 100MHz at the moment.

 I've guess you have seen that the QUAD board which uses
 2 * 82546EB plus a PCI-bridge sets the speed between the 
 onboard bridge and 82546 chips to 120 MHz.

 Cheers.
					--ro
