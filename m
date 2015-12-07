From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: cdc_ncm: add "ndp_to_end" sysfs attribute
Date: Sun, 06 Dec 2015 22:52:30 -0500 (EST)
Message-ID: <20151206.225230.1940853097679776431.davem@davemloft.net>
References: <1449438435-10823-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	mrkiko.rs@gmail.com
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34993 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755373AbbLGDwc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Dec 2015 22:52:32 -0500
In-Reply-To: <1449438435-10823-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Sun,  6 Dec 2015 22:47:15 +0100

> Adding a writable sysfs attribute for the "NDP to end"
> quirk flag.
>=20
> This makes it easier for end users to test new devices for
> this firmware bug.  We've been lucky so far, but we should
> not depend on reporters capable of rebuilding the driver.
>=20
> Cc: Enrico Mioso <mrkiko.rs@gmail.com>
> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>

Applied, thanks.
