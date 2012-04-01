From: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
Subject: Re: be2net: when can I expect roce support patch will be merged?
Date: Sun, 1 Apr 2012 14:36:18 -0700
Message-ID: <CAL1RGDVsXvMJ58Xa8BUoXRnWmnG2=7CVtJ5GF_cdFQAk61ng7g@mail.gmail.com>
References: <88B766C272F2C64B944B21AD078333151C965B92D3@EXMAIL.ad.emulex.com> <20120401.151154.1033862070046707491.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Parav.Pandit-laKkSmNT4hbQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120401.151154.1033862070046707491.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 1, 2012 at 12:11 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
>> Did you get chance to merge below be2net patch for supporing RoCE driver?
>> http://marc.info/?l=linux-rdma&m=133279326217836&w=2

> The net-next tree isn't open, so you'll have to resubmit those
> patches to netdev once it is.

Dave, how would you feel about me merging these two prereq patches
for 3.5, so that I can simply merge the ocrdma itself easily?  That saves
me having to merge some arbitrary point in net-next history into my tree
or other inconvenience for you (like merging ocrdma through your tree).

Anyway, I don't have a big problem whatever way you want to go, so just
let me know...

 - R.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
