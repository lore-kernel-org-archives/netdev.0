From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: Re: [PATCH] phylib: add mdio-gpio bus driver
Date: Fri, 24 Oct 2008 18:24:16 +0300
Message-ID: <4901E8A0.9060109@teltonika.lt>
References: <20081024152112.11695.74341.stgit@Programuotojas.82-135-208-232.ip.zebra.lt>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from 81-7-68-229.static.zebra.lt ([81.7.68.229]:58287 "EHLO
	teltonika.lt" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752153AbYJXPYP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Oct 2008 11:24:15 -0400
Received: from 82-135-208-232.static.zebra.lt (HELO Programuotojas.82-135-208-232.ip.zebra.lt) (paulius.zaleckas@[82.135.208.232])
          (envelope-sender <paulius.zaleckas@teltonika.lt>)
          by teltonika.lt (qmail-ldap-1.03) with SMTP
          for <netdev@vger.kernel.org>; 24 Oct 2008 15:23:13 -0000
In-Reply-To: <20081024152112.11695.74341.stgit@Programuotojas.82-135-208-232.ip.zebra.lt>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paulius Zaleckas wrote:
> Useful for machines where PHY control is connected to GPIO.
> This driver also supports interrupts from PHY.
> 
> Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
> ---
> 
>  drivers/net/phy/Kconfig     |    6 +
>  drivers/net/phy/Makefile    |    1 
>  drivers/net/phy/mdio-gpio.c |  202 +++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 209 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/phy/mdio-gpio.c

Oops. mdio-gpio.h is missing. I will resend patch.
