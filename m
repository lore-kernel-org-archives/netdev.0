From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] Add ptp vlan support
Date: Mon, 07 Jul 2014 16:58:11 -0700 (PDT)
Message-ID: <20140707.165811.2162088078754102232.davem@davemloft.net>
References: <1403863151-13337-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: richardcochran@gmail.com, kaber@trash.net, netdev@vger.kernel.org
To: stefan.sorensen@spectralink.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47708 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752412AbaGGX6O convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2014 19:58:14 -0400
In-Reply-To: <1403863151-13337-1-git-send-email-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Stefan S=F8rensen <stefan.sorensen@spectralink.com>
Date: Fri, 27 Jun 2014 11:59:08 +0200

> This patch series adds functionality for running ptp/ieee1588 over vl=
an.
>=20
> Changes since v1:
>   Split ptp class check simplification onto seperate patch

Series applied, but really longer term we need a much more generic
solution to "ptp over encapsulation X".
