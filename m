From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: Re: [PATCH] hso should register as a WWAN rfkill device, not WLAN
Date: Tue, 04 Nov 2008 13:35:28 +0200
Message-ID: <49103380.4060005@teltonika.lt>
References: <20081104111118.GQ3162@earth.li>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Marcel Holtmann <marcel@holtmann.org>,
	linux-usb@vger.kernel.org
To: Jonathan McDowell <noodles@earth.li>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 81-7-68-229.static.zebra.lt ([81.7.68.229]:43571 "EHLO
	teltonika.lt" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751007AbYKDLfb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Nov 2008 06:35:31 -0500
In-Reply-To: <20081104111118.GQ3162@earth.li>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jonathan McDowell wrote:
> Currently the hso driver registers a WLAN rfkill switch, which is
> intended for 802.11 wireless network devices. Given that this driver
> supports GSM/HSPA devices it's more appropriate to register a WWAN
> rfkill switch type.

Cool!!! We both sent the same patch almost at the same time :)

> Signed-Off-By: Jonathan McDowell <noodles@earth.li>
