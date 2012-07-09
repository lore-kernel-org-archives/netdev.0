From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: qmi_wwan: add ZTE MF60
Date: Mon, 09 Jul 2012 00:18:24 -0700 (PDT)
Message-ID: <20120709.001824.719281318429771941.davem@davemloft.net>
References: <1341486813-27600-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53642 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752499Ab2GIHSZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 03:18:25 -0400
In-Reply-To: <1341486813-27600-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Thu,  5 Jul 2012 13:13:33 +0200

> Adding a device with limited QMI support. It does not support
> normal QMI_WDS commands for connection management. Instead,
> sending a QMI_CTL SET_INSTANCE_ID command is required to
> enable the network interface:
>=20
>   01 0f 00 00 00 00 00 00  20 00 04 00 01 01 00 00
>=20
> A number of QMI_DMS and QMI_NAS commands are also supported
> for optional device management.
>=20
> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>

Applied.
