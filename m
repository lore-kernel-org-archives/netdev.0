From: Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>
Subject: Re: wireless extensions vs. 64-bit architectures
Date: Thu, 8 Mar 2007 14:30:58 -0800
Message-ID: <20070308223058.GA24960@bougret.hpl.hp.com>
References: <20070306171316.GA19669@bougret.hpl.hp.com> <200703061943.07350.mb@bu3sch.de> <20070307020310.GA20466@bougret.hpl.hp.com> <1173364747.14001.7.camel@johannes.berg> <20070308184954.GA24485@bougret.hpl.hp.com> <1173382042.3248.63.camel@johannes.berg> <20070308193412.GG23040@devicescape.com> <1173382802.3248.68.camel@johannes.berg> <20070308221128.GA24884@bougret.hpl.hp.com> <20070308141756.efdfd6da.randy.dunlap@oracle.com>
Reply-To: jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Jouni Malinen <jkm-r/za7OOdgF0ztatW0fm/fQ@public.gmane.org>,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070308141756.efdfd6da.randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 08, 2007 at 02:17:56PM -0800, Randy Dunlap wrote:
> On Thu, 8 Mar 2007 14:11:28 -0800 Jean Tourrilhes wrote:
> > 
> > 	Third possibility : we declare 32 bit userspace on 64 bit
> > kernel as not supported and advise users to get a 64 bit
> > userspace. The number of bug report on that issue would suggest that
> > very few users are in this case.
> 
> I think that this is not actually an option since
> powerpc64 is all 32-bit userspace.
> Maybe some other arch-es are like this also (?).

	Then, I assume that the powerpc64 must be using a magic
version of iwconfig to configure wireless interfaces, because I only
ever got one other bug report on the issue. They should have sent the
patch to Johannes, because now I know about their unauthorised version
of iwconfig.
	Thanks,

	Jean
