From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/1] net: cdc-phonet: Staticize usbpn_probe
Date: Fri, 20 Sep 2013 14:42:24 -0400 (EDT)
Message-ID: <20130920.144224.1940661875859472358.davem@davemloft.net>
References: <1379573126-4879-1-git-send-email-sachin.kamat@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, remi@remlab.net
To: sachin.kamat@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39315 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752129Ab3ITSmZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Sep 2013 14:42:25 -0400
In-Reply-To: <1379573126-4879-1-git-send-email-sachin.kamat@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sachin Kamat <sachin.kamat@linaro.org>
Date: Thu, 19 Sep 2013 12:15:26 +0530

> 'usbpn_probe' is referenced only in this file. Make it static.
>=20
> Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
> Acked-by: R=E9mi Denis-Courmont <remi@remlab.net>
> Cc: R=E9mi Denis-Courmont <remi@remlab.net>

Applied to net-next
