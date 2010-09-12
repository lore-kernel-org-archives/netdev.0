From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [Bug #16626] Machine hangs with EIP at skb_copy_and_csum_dev
Date: Sun, 12 Sep 2010 08:55:09 -0700 (PDT)
Message-ID: <20100912.085509.193705327.davem@davemloft.net>
References: <20100908.103256.112592448.davem@davemloft.net>
	<201009082221.16356.rjw@sisk.pl>
	<4C8C7957.7080207@fs.uni-ruse.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rjw-KKrjLPT3xs0@public.gmane.org, jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org, kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
To: pvp-lsts-s6OjJRe3oxUfI6EYonfoRA@public.gmane.org
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4C8C7957.7080207-s6OjJRe3oxUfI6EYonfoRA@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Plamen Petrov <pvp-lsts-s6OjJRe3oxUfI6EYonfoRA@public.gmane.org>
Date: Sun, 12 Sep 2010 09:55:19 +0300

> Now that both commits that fix my problems are in Linus' tree, the
> bug can be closed, but these fixes should go in 2.6.35.y, too.
> So, CCing -stable.

You don't need to do this, I will submit whatever is appropriate for
networking to -stable as needed.
