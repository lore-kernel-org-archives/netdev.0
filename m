From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net,stable] net: huawei_cdc_ncm: add "subclass 3"
 devices
Date: Thu, 17 Jul 2014 16:51:10 -0700 (PDT)
Message-ID: <20140717.165110.2207287835959587849.davem@davemloft.net>
References: <1405596849-11800-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	mrkiko.rs@gmail.com
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41603 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758610AbaGQXvL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 19:51:11 -0400
In-Reply-To: <1405596849-11800-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Thu, 17 Jul 2014 13:34:09 +0200

> Huawei's usage of the subclass and protocol fields is not 100%
> clear to us, but there appears to be a very strict system.
>=20
> A device with the "shared" device ID 12d1:1506 and this NCM
> function was recently reported (showing only default altsetting):
 ...
> Cc: Enrico Mioso <mrkiko.rs@gmail.com>
> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>

Applied and queued up for -stable.
