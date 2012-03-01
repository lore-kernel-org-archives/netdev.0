From: Roland Stigge <stigge@antcom.de>
Subject: Re: [PATCH v3] lpc32xx: Added ethernet driver
Date: Thu, 01 Mar 2012 21:42:21 +0100
Message-ID: <4F4FDF2D.5040508@antcom.de>
References: <1330364539-23152-1-git-send-email-stigge@antcom.de> <201202271949.03144.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	alexander.h.duyck@intel.com, eilong@broadcom.com,
	ian.campbell@citrix.com, netdev@vger.kernel.org,
	w.sang@pengutronix.de, linux-kernel@vger.kernel.org,
	kevin.wells@nxp.com, linux-arm-kernel@lists.infradead.org,
	baruch@tkos.co.il, joe@perches.com
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201202271949.03144.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 27/02/12 20:49, Arnd Bergmann wrote:
> Are you sure that npx is actually the origin of this controller?
> If they only licensed the IP themselves, it would be better to list
> it under the name of the actual creator so that the next person
> who has the same core can find it.

I have no hint for another origin of this core (see manual). However, as
soon as we get new info on this, we can move the driver easily.

Thanks to all of you for your suggestions, I will include all the
suggested changes an repost an updated driver.

Roland
