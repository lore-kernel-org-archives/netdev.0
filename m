From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH] zd1211rw-mac80211: limit URB buffering in tx path
Date: Tue, 1 May 2007 22:16:56 -0400
Message-ID: <20070502021656.GB5621@tuxdriver.com>
References: <20070501030100.BDE3D7B409F@zog.reactivated.net> <20070501123411.081c43c6@logostar.upir.cz> <20070501195008.GA14294@p15091797.pureserver.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Jiri Benc <jbenc-AlSwsSmVLrQ@public.gmane.org>, Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070501195008.GA14294-WhJF3imHnk+bHbQv0o6mQ2hcgWyyV7dXYZdqe9AaVak@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, May 01, 2007 at 09:50:08PM +0200, Ulrich Kunitz wrote:
> On 07-05-01 12:34 Jiri Benc wrote:

> > It is :-) Look for ieee80211_wake_queues. But as I said, you shouldn't need
> > that.
> 
> I provided the patch to add ieee80211_wake_queues(). Sorry for
> missing the moment, when it has been integrated. I will update the
> patch.

No need, I have adjusted the patch accordingly.

Thanks,

John
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
