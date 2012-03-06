From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] caif-hsi: Set default MTU to 4096
Date: Tue, 06 Mar 2012 16:29:20 -0500 (EST)
Message-ID: <20120306.162920.1430620346439798392.davem@davemloft.net>
References: <1330886338-4814-1-git-send-email-abi.dmitryt@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sjurbren@gmail.com
To: abi.dmitryt@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39942 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756390Ab2CFV3Y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2012 16:29:24 -0500
In-Reply-To: <1330886338-4814-1-git-send-email-abi.dmitryt@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Dmitry Tarnyagin <abi.dmitryt@gmail.com>
Date: Sun,  4 Mar 2012 19:38:58 +0100

> From: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>
>=20
> Default MTU for CAIF HSI was wrongly set to 15 * 4092 bytes.
> The patch sets default MTU size to 4096.
>=20
> Signed-off-by: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>

Applied.
