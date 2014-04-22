From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH 0/7] net: rfkill: gpio: Add device tree support
Date: Tue, 22 Apr 2014 17:06:42 +0200
Message-ID: <1398179202.4211.15.camel@jlt4.sipsolutions.net>
References: <1397544101-18135-1-git-send-email-wens@csie.org>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, "John W. Linville"
 <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
  Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, Heikki Krogerus
 <heikki.krogerus-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, Mika Westerberg
 <mika.westerberg-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>, linux-gpio-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Return-path: <linux-sunxi+bncBD2NJ5WGSUOBBJEL3KNAKGQEYMWKLIY-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <1397544101-18135-1-git-send-email-wens-jdAy2FN1RRM@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Tue, 2014-04-15 at 14:41 +0800, Chen-Yu Tsai wrote:

> The first 2 patches should go through the gpio tree. The 4 rfkill-gpio
> patches should go through the same tree that Heikki's patches are
> in. Maxime, can you take the last one?

Are there no dependencies? Maybe it'd be easier if you sent it as
separate patch series then?

I can take those four patches into my topic branch on top of Heikki's
patches, but in any case, there seem to be a bunch of
comments/discussions so for now I'm not going to do anything with them.

johannes
