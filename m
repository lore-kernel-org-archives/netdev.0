From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] caif: Remove bad WARN_ON in caif_dev
Date: Tue, 17 Jan 2012 10:47:33 -0500 (EST)
Message-ID: <20120117.104733.2158489778862416358.davem@davemloft.net>
References: <1326805394-2662-1-git-send-email-sjur.brandeland@stericsson.com>
	<1326805394-2662-2-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54826 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754384Ab2AQPrj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 10:47:39 -0500
In-Reply-To: <1326805394-2662-2-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>
Date: Tue, 17 Jan 2012 14:03:14 +0100

> Remove WARN_ON and bad handling of SKB without destructor callback
> in caif_flow_cb. SKB without destructor cannot be handled as an
> error case.
>=20
> Signed-off-by: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>

Applied.
