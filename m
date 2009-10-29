From: Bartlomiej Zolnierkiewicz <bzolnier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: pull request: wireless-next-2.6 2009-10-28
Date: Thu, 29 Oct 2009 13:45:05 +0100
Message-ID: <200910291345.05888.bzolnier@gmail.com>
References: <20091028211031.GF2856@tuxdriver.com> <200910291212.41656.bzolnier@gmail.com> <20091029.051509.119751790.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20091029.051509.119751790.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thursday 29 October 2009 13:15:09 David Miller wrote:
> From: Bartlomiej Zolnierkiewicz <bzolnier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Thu, 29 Oct 2009 12:12:41 +0100
> 
> > What is even more disappointing (especially after all that "working with"
> > preaching) is that the patch is now in net-next-2.6..
> 
> John is the wireless maintainer, I take his tree in since the changes
> in there have his blessing.
> 
> If you have a problem with some change in there, work it out with him
> and he'll send the fixed up changes to me thereafterwards.

What do you mean by that?

That *I* should be fixing the patch in question instead of the submitter?

Do some different rules apply in the networking than in other parts of
the kernel that I'm not aware of?

There were valid concerns raised on the initial rt2800pci patch submission,
yet two days later patch is in John's tree, after few more days it is in yours
tree and happily on his way into 2.6.33.

Until issues mentioned in:

	http://lkml.org/lkml/2009/10/17/81

are addressed rt2800pci shouldn't be queued for Linus' tree.

[ Please note that this driver doesn't work at all currently so the standard
  argument of having hardware support early upstream cannot be applied here. ]

--
Bartlomiej Zolnierkiewicz
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
