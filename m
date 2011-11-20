From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [bug] af_unix: Reading from a stream socket may lock the
 concurrent poll() call
Date: Sun, 20 Nov 2011 15:31:56 -0500 (EST)
Message-ID: <20111120.153156.1383147368726575639.davem@davemloft.net>
References: <CAHjqzy7dhqi22yPJX=DP4x916hVXDY2WaDbdmnTEQ54n6qpMXw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: himeraster-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAHjqzy7dhqi22yPJX=DP4x916hVXDY2WaDbdmnTEQ54n6qpMXw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Alexey Moiseytsev <himeraster-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Mon, 21 Nov 2011 00:19:02 +0400

> Other info:
> $ uname -srmo
> Linux 2.6.32-5-amd64 x86_64 GNU/Linux

There have been numerous AF_UNIX bug fixes since that release, please try
to reproduce your problem with current kernels.

Thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
