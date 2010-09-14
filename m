From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] enable getsockopt() for IP_NODEFRAG
Date: Mon, 13 Sep 2010 19:57:43 -0700 (PDT)
Message-ID: <20100913.195743.70199815.davem@davemloft.net>
References: <4C8B2130.7030605@gmail.com>
	<20100912215230.GA2091@jolsa.Belkin>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org,
	kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100912215230.GA2091-Iosbtnj8/lepmqaOOeWOyQ@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date: Sun, 12 Sep 2010 23:52:30 +0200

> On Sat, Sep 11, 2010 at 08:26:56AM +0200, Michael Kerrisk wrote:
>> Hello Jiri
>> 
>> While integrating your man-pages patch for IP_NODEFRAG, I noticed 
>> that this option is settable by setsockopt(), but not gettable by 
>> getsockopt(). I suppose this is not intended. The (untested, 
>> trivial) patch below adds getsockopt() support.
>> 
>> The patch is against 2.6.36-rc3.
>> 
>> Cheers,
>> 
>> Michael
>> 
>> PS I've just configured Thunderbird on this machine, hopefully the 
>> patch is not mangled. Please let me know if there are problems.
> hi,
> 
> applied ok, compiled ok ;) thanks
> 
> Acked-by: Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Applied, thanks everyone.
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
