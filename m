From: Yevgeny Petrilin <yevgenyp@mellanox.com>
Subject: RE: [PATCH net 0/7] mlx4: Bug fixes and cleanups
Date: Wed, 15 Feb 2012 06:54:07 +0000
Message-ID: <953B660C027164448AE903364AC447D25D0B68A1@MTLDAG02.mtl.com>
References: <4F3A8DB5.3020703@mellanox.co.il>
	<20120214.143023.281327914225614215.davem@davemloft.net>
	<74A0102445410646AFACC089FD94803A5CEEACB5@MTLDAG02.mtl.com>
 <20120214.152238.470074857804516115.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Eugenia Emantayev <eugenia@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:59904 "HELO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751370Ab2BOG43 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Feb 2012 01:56:29 -0500
In-Reply-To: <20120214.152238.470074857804516115.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> > Some of the patches fix very harmful memory leaks and corruptions.
> 
> Then submit the patches properly, don't mix cleanups in there if it matters so much to you.

We will split the series in 2 parts, 1 for net and the other for net-next

Yevgeny
