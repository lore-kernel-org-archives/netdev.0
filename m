From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [net-2.6 PATCH] af_packet: move strict addr_len check right
 before dev_[mc/unicast]_[add/del]
Date: Wed, 03 Mar 2010 01:06:28 -0800 (PST)
Message-ID: <20100303.010628.41962003.davem@davemloft.net>
References: <1267578048.14049.11.camel@mj>
	<20100303064001.GB2648@psychotron.redhat.com>
	<20100303090512.GB2961@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tcpdump-workers-YE1jQ5a0g24KACXWX4p+q9i2O/JbrIOy@public.gmane.org,
	proski-mXXj517/zsQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100303090512.GB2961-YzwxZg+R7evMbnheQZGK0N5OCZ2W11yPFxja6HXR22MAvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jiri Pirko <jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date: Wed, 3 Mar 2010 10:05:13 +0100

> Wed, Mar 03, 2010 at 07:40:01AM CET, jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org wrote:
>>Subject: [net-2.6 PATCH] af_packet: move strict addr_len check right before dev_[mc/unicast]_[add/del]
> 
> Dave please apply this against net-next-2.6. I see that 914c8ad2d18b is still not in
> net-2.6.

Would you relax?

I just rebased net-2.6 and net-next-2.6 after Linus took in my
changes and I just applied your regression fix to my tree and
was about to let you know I applied it.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
