From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next 4/4] caif: Replace BUG_ON with WARN_ON.
Date: Tue, 06 Dec 2011 17:22:31 -0500 (EST)
Message-ID: <20111206.172231.1814031149924141501.davem@davemloft.net>
References: <1323209744-9718-1-git-send-email-sjur.brandeland@stericsson.com>
	<1323209744-9718-4-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, roar.forde@stericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34621 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755293Ab1LFWWg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 17:22:36 -0500
In-Reply-To: <1323209744-9718-4-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>
Date: Tue,  6 Dec 2011 23:15:44 +0100

> From: Roar F=F8rde <roar.forde@stericsson.com>
>=20
> BUG_ON is too strict in a number of circumstances,
> use WARN_ON instead. Protocol errors should not halt the system.
>=20
> Signed-off-by: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>
> ---
> Since v1: removed and changed some OOM related printouts.

Applied.
