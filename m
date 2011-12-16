From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4 net-next] net:core: use IS_ENABLED
Date: Fri, 16 Dec 2011 15:50:19 -0500 (EST)
Message-ID: <20111216.155019.500819404355873846.davem@davemloft.net>
References: <igorm@etf.rs>
	<1323694705-2793-1-git-send-email-igorm@etf.rs>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: igorm@etf.rs
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58566 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752164Ab1LPUu0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 15:50:26 -0500
In-Reply-To: <1323694705-2793-1-git-send-email-igorm@etf.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: igorm@etf.rs
Date: Mon, 12 Dec 2011 04:58:22 -0800

> From: Igor Maravi=E6 <igorm@etf.rs>
>=20
> Use IS_ENABLED(CONFIG_FOO)
> instead of defined(CONFIG_FOO) || defined (CONFIG_FOO_MODULE)
>=20
> Signed-off-by: Igor Maravi=E6 <igorm@etf.rs>

Applied.
