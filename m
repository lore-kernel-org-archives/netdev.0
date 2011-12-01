From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] caif: Allow cfpkt_extr_head to process
 empty message
Date: Wed, 30 Nov 2011 23:37:57 -0500 (EST)
Message-ID: <20111130.233757.594296690782414277.davem@davemloft.net>
References: <1322680968-6470-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58417 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754002Ab1LAEiE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 23:38:04 -0500
In-Reply-To: <1322680968-6470-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>
Date: Wed, 30 Nov 2011 20:22:46 +0100

> Allow NULL pointer in cfpkt_extr_head in order to
> skip past header data.
>=20
> Signed-off-by: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>

Applied.
