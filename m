From: Kasper Sandberg <lkml@metanurb.dk>
Subject: Re: 8169 Intermittent ifup Failure Issue With RTL8102E Chipset in
	Intel's New D945GCLF Atom Board (Not the Initial Modprobe Crash, Another
	Problem)
Date: Fri, 11 Jul 2008 15:35:24 +0200
Message-ID: <1215783324.11909.185.camel@localhost>
References: <4861800B.90703@nscus.com>
	 <20080625213142.GA29890@electric-eye.fr.zoreil.com>
	 <48640535.2050000@nscus.com>
	 <20080626215918.GC2555@electric-eye.fr.zoreil.com>
	 <1215435236.11909.121.camel@localhost>  <487232F4.6000206@dell.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Michael Grollman <mgrollman@nscus.com>, netdev@vger.kernel.org,
	akpm@linux-foundation.org, linux-pci@vger.kernel.org
To: Mario Limonciello <mario_limonciello@dell.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <487232F4.6000206@dell.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2008-07-07 at 10:15 -0500, Mario Limonciello wrote:
> Kasper:
> 
> Particularly try the patch that I posted to the list.  It solved the
> ifup (and resume) failures for me on two platforms using that chipset.
Sorry, i am not subscribed to netdev or pci list, could you post here
aswell?

> 
> Regards
> 
> Kasper Sandberg wrote:
> > On Thu, 2008-06-26 at 23:59 +0200, Francois Romieu wrote:
> >   
> > Sorry for the delay, i had to do an onsite thing in another country, so
> > i first see your message now.
> >
> > Would it be okay if i took rc9 instead? also, i saw you posted a set of
> > patches to sync more with realteks code, is this something you would
> > like me to test too, or aswell? (remember, i have the 8111c).
> >
> > Btw, a thought just crossed my mind as to a possible reason why this
> > might be happening, i was googling around, and it seems the TWO nic's
> > are supposed to have some sort of hardware bonding thing, could it be
> > because such stuff isnt handled?
> >
> > mvh.
> > Kasper Sandberg
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >   
> 
