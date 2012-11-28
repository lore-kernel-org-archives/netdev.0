From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: qmi_wwan: add Huawei E173
Date: Wed, 28 Nov 2012 11:24:01 -0500 (EST)
Message-ID: <20121128.112401.1001144507671878052.davem@davemloft.net>
References: <1353859439-18260-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	tschaefer@t-online.de
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50113 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752545Ab2K1QYD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 11:24:03 -0500
In-Reply-To: <1353859439-18260-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Sun, 25 Nov 2012 17:03:59 +0100

> The Huawei E173 is a QMI/wwan device which normally appear
> as 12d1:1436 in Linux. The descriptors displayed in that
> mode will be picked up by cdc_ether.  But the modem has
> another mode with a different device ID and a slightly
> different set of descriptors. This is the mode used by
> Windows like this:
>=20
> 3Modem:      USB\VID_12D1&PID_140C&MI_00\6&3A1D2012&0&0000
> Networkcard: USB\VID_12D1&PID_140C&MI_01\6&3A1D2012&0&0001
> Appli.Inter: USB\VID_12D1&PID_140C&MI_02\6&3A1D2012&0&0002
> PC UI Inter: USB\VID_12D1&PID_140C&MI_03\6&3A1D2012&0&0003
>=20
> Reported-by: Thomas Sch=E4fer <tschaefer@t-online.de>
> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>

Applied.
