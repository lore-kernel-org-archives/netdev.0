From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: fix vector traveling while looking for an
 empty entry
Date: Tue, 27 Mar 2012 22:41:49 -0400 (EDT)
Message-ID: <20120327.224149.914675471504529880.davem@davemloft.net>
References: <1332832135-22054-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, eilong@broadcom.com, zenczykowski@gmail.com
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47953 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757601Ab2C1Clx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 22:41:53 -0400
In-Reply-To: <1332832135-22054-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Dmitry Kravkov" <dmitry@broadcom.com>
Date: Tue, 27 Mar 2012 09:08:55 +0200

> Fixes the bug that may prevent from mac to be configured,
> while there is an empty slot for it.
>=20
> Reported-by: Maciej =AFenczykowski <zenczykowski@gmail.com>
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>

Applied.
