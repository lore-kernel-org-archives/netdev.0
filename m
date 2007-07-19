From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH v2 2/2] mac80211: implement ERP info change notifications
Date: Thu, 19 Jul 2007 15:16:33 -0400
Message-ID: <20070719191633.GE6603@tuxdriver.com>
References: <20070715140822.C9DC07B409F@zog.reactivated.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jbenc-AlSwsSmVLrQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org
To: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070715140822.C9DC07B409F-k/4jFdqg8LLlyo9zxV8I99HuzzzSOjJt@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 15, 2007 at 03:08:22PM +0100, Daniel Drake wrote:
> zd1211rw and bcm43xx are interested in being notified when ERP IE conditions
> change, so that they can reprogram a register which affects how control frames
> are transmitted.
> 
> This patch adds an interface similar to the one that can be found in softmac.
> 
> Signed-off-by: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>

Jiri, Michael -- just like the other, this applies to upstream w/
just some offsets if you ignore the driver bits that aren't upstream.
Let me know if you are happy w/ this patch.

John
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
