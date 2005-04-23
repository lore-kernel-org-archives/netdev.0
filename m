From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: NAPI, e100, and system performance problem
Date: Sat, 23 Apr 2005 19:14:38 +0200
Message-ID: <17002.33406.419284.821059@robur.slu.se>
References: <C925F8B43D79CC49ACD0601FB68FF50C03A633C7@orsmsx408>
	<Pine.LNX.4.61.0504180943290.15052@linux.site>
	<1113855967.7436.39.camel@localhost.localdomain>
	<20050419055535.GA12211@sgi.com>
	<m1hdhzyrdz.fsf@muc.de>
	<1114173195.7679.30.camel@localhost.localdomain>
	<20050422172108.GA10598@muc.de>
	<1114193902.7978.39.camel@localhost.localdomain>
	<20050422232831.GB6462@sgi.com>
	<20050423094038.72a8da73@localhost.localdomain>
	<20050422164301.724343f6.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, gnb@sgi.com, hadi@cyberus.ca,
        ak@muc.de, akepner@sgi.com, jesse.brandeburg@intel.com,
        netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050422164301.724343f6.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


David S. Miller writes:

 > With the dynamic schemes comes a new issue, how quickly to respond
 > to changes in traffic patterns.

 So true... spoiled months with this to trying to find acceptable 
 mitigation settings for all rates and for all packet sizes.

 Yes minimal mitigation settings with NAPI is probably the best way
 to go. 

 Cheers.
					--ro
 
