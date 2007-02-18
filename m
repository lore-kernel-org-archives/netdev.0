From: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] zd1211rw: changed GFP_NOFS to GFP_KERNEL
Date: Sun, 18 Feb 2007 15:58:15 -0500
Message-ID: <45D8BDE7.10001@gentoo.org>
References: <20070218202823.9C4A07B409F@zog.reactivated.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070218202823.9C4A07B409F-k/4jFdqg8LLlyo9zxV8I99HuzzzSOjJt@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Daniel Drake wrote:
> From: Ulrich Kunitz <kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org>
> 
> Michael Buesch commented that GFP_NOFS should not be used in a
> network driver. This patch implements it for zd1211rw-d80211.

Forgot to update the description. As you might have figured, this 
version of the patch is for wireless-2.6, and the earlier one was for
wireless-dev.

Daniel
