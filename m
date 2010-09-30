From: Marc Aurele La France <tsi@ualberta.ca>
Subject: Re: RFC: MTU for serving NFS on Infiniband
Date: Thu, 30 Sep 2010 12:50:12 -0600 (Mountain Daylight Time)
Message-ID: <alpine.WNT.2.00.1009301248250.1128@cluij.ucs.ualberta.ca>
References: <alpine.LNX.2.00.1008230842290.9325@abcyxhiz.aict.ualberta.ca> <20100823080543.319143e3@nehalam> <alpine.WNT.2.00.1008240856170.2000@cluij.ucs.ualberta.ca> <1282672647.2302.15.camel@achroite.uk.solarflarecom.com> <alpine.WNT.2.00.1008241338470.1132@cluij.ucs.ualberta.ca>
 <1282688441.22839.34.camel@localhost> <20100824153920.63360072@s6510> <alpine.WNT.2.00.1008251408520.632@cluij.ucs.ualberta.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.WNT.2.00.1008251408520.632@cluij.ucs.ualberta.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 26 Aug 2010, Marc Aurele La France wrote:
> I do want to thank you, however, for reminding me of TCP.  It's something 
> 20/20 hindsight says I should have checked out before starting this thread. 
> Logistically, it'll be a few days before I can do so though.  If that allows 
> me to increase the MTU all the way up to 65520, then this UDP thing will 
> likely remain unresolved.

Just to close off on this.  It's been a few weeks now, but moving to NFS 
over TCP allows me to increase the MTU all the way up to 65520 without 
issues.

Thanks for the help.

Marc.

+----------------------------------+----------------------------------+
|  Marc Aurele La France           |  work:   1-780-492-9310          |
|  Academic Information and        |  fax:    1-780-492-1729          |
|    Communications Technologies   |  email:  tsi@ualberta.ca         |
|  352 General Services Building   +----------------------------------+
|  University of Alberta           |                                  |
|  Edmonton, Alberta               |    Standard disclaimers apply    |
|  T6G 2H1                         |                                  |
|  CANADA                          |                                  |
+----------------------------------+----------------------------------+
