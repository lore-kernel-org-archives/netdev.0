From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] caif: make zero a legal caif connetion id.
Date: Sun, 11 Mar 2012 15:38:37 -0700 (PDT)
Message-ID: <20120311.153837.1034038001602920674.davem@davemloft.net>
References: <1331497712-13534-1-git-send-email-sjur.brandeland@stericsson.com>
	<1331497712-13534-2-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sjurbren@gmail.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41783 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751800Ab2CKWim convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Mar 2012 18:38:42 -0400
In-Reply-To: <1331497712-13534-2-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>
Date: Sun, 11 Mar 2012 21:28:32 +0100

> Connection ID configured through RTNL must allow zero as
> connection id. If connection-id is not given when creating the
> interface, configure a loopback interface using ifindex as
> connection-id.
>=20
> Signed-off-by: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>

Applied.
