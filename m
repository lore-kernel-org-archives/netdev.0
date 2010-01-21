From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 1/6] netdev: bfin_mac: handler RX
 status errors
Date: Thu, 21 Jan 2010 01:33:58 -0800 (PST)
Message-ID: <20100121.013358.45891896.davem@davemloft.net>
References: <1263899307-10627-1-git-send-email-vapier@gentoo.org>
	<20100121.011445.26519711.davem@davemloft.net>
	<8bd0f97a1001210131w74d53c82h3f548e645bb14be7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, pmeerw-jW+XmwGofnusTnJN9+BGXg@public.gmane.org,
        uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
To: vapier.adi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org>
In-Reply-To: <8bd0f97a1001210131w74d53c82h3f548e645bb14be7-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://blackfin.uclinux.org/mailman/options/uclinux-dist-devel>,
	<mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=unsubscribe>
List-Archive: <http://blackfin.uclinux.org/pipermail/uclinux-dist-devel>
List-Post: <mailto:uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org>
List-Help: <mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=help>
List-Subscribe: <https://blackfin.uclinux.org/mailman/listinfo/uclinux-dist-devel>,
	<mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=subscribe>
Sender: uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
Errors-To: uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Mike Frysinger <vapier.adi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Thu, 21 Jan 2010 04:31:17 -0500

> On Thu, Jan 21, 2010 at 04:14, David Miller wrote:
>> This patch set doesn't apply cleanly to net-next-2.6, please
>> respin.
> 
> i thought you said you merged the patch i sent out earlier ?
> bfin_mac: use the newer CLKBUFOE bit name via asm/dpmc.h

I did, to net-2.6 since it fixed a build.

If you are sending me patches that depend upon net-2.6 changes,
you have to mention that in your patch submission.

Otherwise how do I know that I need to merge net-2.6 into
net-next-2.6 in order to apply your patches?
