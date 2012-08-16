From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Subject: Re: [patch net-next v2 01/15] net: introduce upper device lists
Date: Thu, 16 Aug 2012 07:48:59 +0200
Message-ID: <20120816054859.GA1769@minipsycho.orion>
References: <1344956748-2099-2-git-send-email-jiri@resnulli.us>
 <1344983624.2690.77.camel@bwh-desktop.uk.solarflarecom.com>
 <20120815074612.GB1726@minipsycho.orion>
 <20120815.151549.1835466517645273818.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, fubar-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org,
	andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org, divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, jitendra.kalsaria-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org,
	sony.chacko-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org, linux-driver-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	ursula.braun-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org, blaschka-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
	linux390-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org, shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org, therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org,
	gregory.v.rose-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bridge-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	fbl-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120815.151549.1835466517645273818.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Thu, Aug 16, 2012 at 12:15:49AM CEST, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org wrote:
>From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
>Date: Wed, 15 Aug 2012 09:46:12 +0200
>
>> You are probably right. I'm not sure how to handle this correctly
>> though. Adding some hard limit number might not be correct.
>
>I would just use a hard limit of something like 8 for now, and if we
>need to expand this limit we can consider how to do so with real known
>usage in mind rather than pure speculation.

Okay. I will repost the set soon.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
