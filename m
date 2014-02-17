From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net:cpsw: Pass unhandled ioctl's on to generic phy
 ioctl
Date: Mon, 17 Feb 2014 00:30:49 -0500 (EST)
Message-ID: <20140217.003049.1770259997160293076.davem@davemloft.net>
References: <1392558865-18388-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mugunthanvnm@ti.com, netdev@vger.kernel.org
To: stefan.sorensen@spectralink.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40300 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751180AbaBQFau convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 00:30:50 -0500
In-Reply-To: <1392558865-18388-1-git-send-email-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Stefan S=F8rensen <stefan.sorensen@spectralink.com>
Date: Sun, 16 Feb 2014 14:54:25 +0100

> This patch allows the use of a generic timestamping phy connected
> to the cpsw if CPTS support is not enabled. This also adds support
> of the SIOCGMIIREG and SIOCSMIIREG, and moves handling of SIOCGMIIPHY
> to the generic driver.
>=20
> Signed-off-by: Stefan S=F8rensen <stefan.sorensen@spectralink.com>

Applied to net-next, thanks.
