From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 00/11 - GIT PULL] drivers: net: Last block of Remove
 extern from function prototypes
Date: Thu, 26 Sep 2013 11:02:56 -0700
Message-ID: <1380218576.17366.76.camel@joe-AO722>
References: <cover.1380137609.git.joe@perches.com>
	 <20130926.134408.91633054642517467.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	wimax-BPSAo7wm5JOHVYUYWc+uSQ@public.gmane.org, ath10k-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ath9k-devel-juf53994utBLZpfksSYvnA@public.gmane.org,
	brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org
To: David Miller <davem-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130926.134408.91633054642517467.davem-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-09-26 at 13:44 -0400, David Miller wrote:
> From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
> Date: Wed, 25 Sep 2013 12:37:18 -0700
[]
> Pulled, thanks Joe.
> That should be about it for networking right?

Yes for drivers/net/...

There are some more files like:

include/linux/etherdevice.h
include/linux/inetdevice.h
include/linux/net.h
include/linux/netdevice.h
include/linux/skbuff.h

and some netfilter ones:

include/linux/netfilter*.h
include/linux/netfilter/...

and maybe a few others like:

include/linux/atmdev.h
include/linux/fddidevice.h

that I was planning on converting then submitting.

Want those in one more pull request or
maybe individually?

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
