From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 6/6] net: stmmac: revert "support future
 possible different internal phy mode"
Date: Thu, 06 Jul 2017 10:45:14 +0100 (WEST)
Message-ID: <20170706.104514.1212305295126379350.davem@davemloft.net>
References: <20170702123159.6939-1-clabbe.montjoie@gmail.com>
	<20170702123159.6939-7-clabbe.montjoie@gmail.com>
	<20170706085147.GA15728@Red>
Reply-To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To: clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-sunxi+bncBCFPF2XH6UDBBMEN7DFAKGQEK6WU7EY-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <20170706085147.GA15728@Red>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

From: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Thu, 6 Jul 2017 10:51:47 +0200

> On Sun, Jul 02, 2017 at 02:31:59PM +0200, Corentin Labbe wrote:
>> Since internal phy-mode is reserved for non-xMII protocol we cannot use
>> it with dwmac-sun8i
>> This reverts commit 1c2fa5f84683 ("net: stmmac: support future possible different internal phy mode")
>> 
>> Signed-off-by: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> ---
> 
> Hello
> 
> This patch was left not applied but all other patch from this serie was.
> Could you apply it, or perhaps you prefer I resend it with some "Fixes:"

You never need to ask questions like this.

If it's not active in my patchwork queue, you must resend.

Thank you.
