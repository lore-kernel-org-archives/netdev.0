From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH RFC 0/6] net: rfkill: gpio: Add device tree support
Date: Fri, 17 Jan 2014 21:26:32 +0100
Message-ID: <1389990392.10404.10.camel@jlt4.sipsolutions.net>
References: <1389941251-32692-1-git-send-email-wens@csie.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-sunxi@googlegroups.com,
	Maxime Ripard <maxime.ripard@free-electrons.com>,
	linux-wireless@vger.kernel.org
To: Chen-Yu Tsai <wens@csie.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:48392 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753332AbaAQU0q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 15:26:46 -0500
In-Reply-To: <1389941251-32692-1-git-send-email-wens@csie.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-01-17 at 14:47 +0800, Chen-Yu Tsai wrote:

> This patch series adds device tree support to rfkill-gpio, and
> fixes some issues I ran into. This is so we can define and control
> RF devices through the device tree, such as the Broadcom BCM20710
> UART-based Bluetooth device found on the CubieTruck,

> Comments, please?

Does anyone else want to maintain rfkill-gpio? :)

I'm not up to par on all the DT, ACPI and even GPIO stuff it does, and
the rfkill bits in it are really small ...

I'll happily apply the patches if everyone else is happy with them, but
please don't expect me to actually be able to say anything about them.

johannes
