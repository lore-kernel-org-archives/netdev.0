From: jamal <hadi@cyberus.ca>
Subject: Re: Intel and TOE in the news
Date: 21 Feb 2005 16:12:42 -0500
Message-ID: <1109020362.1077.134.camel@jzny.localdomain>
References: <20050220230713.GA62354@muc.de>
	 <200502210332.j1L3WkDD014744@guinness.s2io.com>
	 <20050221115006.GB87576@muc.de> <20050221132844.GU31837@postel.suug.ch>
	 <1108994621.1089.158.camel@jzny.localdomain>
	 <20050221141714.GV31837@postel.suug.ch>
	 <1108996313.1090.178.camel@jzny.localdomain>
	 <20050221153443.GW31837@postel.suug.ch>
	 <1109000925.1076.3.camel@jzny.localdomain>
	 <20050221164006.GY31837@postel.suug.ch>
	 <1109005385.1074.68.camel@jzny.localdomain>
	 <1109016740.25476.2.camel@mcmanus.datapower.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@oss.sgi.com" <netdev@oss.sgi.com>
To: patrick mcmanus <mcmanus@ducksong.com>
In-Reply-To: <1109016740.25476.2.camel@mcmanus.datapower.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-02-21 at 15:12, patrick mcmanus wrote:
> On Mon, 2005-02-21 at 12:03, jamal wrote:
> > after the BSD folks claimed to be
> > doing 1Mpps forwarding (only to find out they used CSA later).
>                            ^^^^^^^^^^^^^^^^^^^^^^^^
> 
> I can't grok this. Can you elucidate?
> 

Credit should go to Harald Welte for pointing this out to me a while
back.
CSA is essentially a direct link to the Northbridge System Controller
(or MCH); there are some speacilized motherboards that have this
feature. So imagine a e1000 with no PCI-X bridge directly connected to
the MCH. The funny thing is it was supposed to be a cost-reduction
concept (no more PCI-X brifge). Refer to my earlier comment about
intel and its chipset division.

cheers,
jamal
