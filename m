From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v6 0/3] The huawei_cdc_ncm driver
Date: Tue, 05 Nov 2013 15:22:05 -0500 (EST)
Message-ID: <20131105.152205.2098582195076844580.davem@davemloft.net>
References: <1383555049-24834-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	mrkiko.rs@gmail.com, oliver@neukum.org
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34217 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754403Ab3KEUWI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Nov 2013 15:22:08 -0500
In-Reply-To: <1383555049-24834-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Mon,  4 Nov 2013 09:50:46 +0100

> Enrico has been kind enough to let me repost his driver with the chan=
ges
> requested by Oliver Neukum during the last review of this series.
>=20
> The changes I have made from Enricos original v5 series to this versi=
on
> are:
>=20
> v6:
>  - fix to avoid corrupting drvstate->pmcount
>  - fix error return value from huawei_cdc_ncm_suspend()
>  - drop redundant testing for subdriver->suspend during resume
>  - broke a few lines to keep within the 80 columns recommendation
>  - rebased on top of current net-next
>=20
> Enrico's orginal introduction to the v5 series follows below.  It exp=
lains
> the background much better than I can.

Looks good, series applied, thanks!
