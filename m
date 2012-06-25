From: David Miller <davem@davemloft.net>
Subject: Re: [net 3/3] caif-hsi: Add missing return in error path
Date: Mon, 25 Jun 2012 16:07:45 -0700 (PDT)
Message-ID: <20120625.160745.1643296185488626232.davem@davemloft.net>
References: <1340571698-17892-1-git-send-email-sjur.brandeland@stericsson.com>
	<1340571698-17892-3-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sjurbren@gmail.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56455 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755051Ab2FYXHq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 19:07:46 -0400
In-Reply-To: <1340571698-17892-3-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: sjur.brandeland@stericsson.com
Date: Sun, 24 Jun 2012 23:01:38 +0200

> From: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>
>=20
> Fix a missing return, causing access to freed memory.
>=20
> Signed-off-by: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>

Applied.
