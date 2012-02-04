From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] caif-hsi: Add RX flip buffer
Date: Sat, 04 Feb 2012 16:05:31 -0500 (EST)
Message-ID: <20120204.160531.1392845191016148021.davem@davemloft.net>
References: <1328279781-4745-1-git-send-email-sjur.brandeland@stericsson.com>
	<1328279781-4745-3-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sjurbren@gmail.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36002 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753928Ab2BDVFi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2012 16:05:38 -0500
In-Reply-To: <1328279781-4745-3-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>
Date: Fri,  3 Feb 2012 15:36:21 +0100

> Implement RX flip buffer in the cfhsi_rx_done function,
> piggy-backed frames is also supported.
> This gives a significant performance gain for CAIF over HSI.
>=20
> Signed-off-by: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>

Applied.
