From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH 13/23 v3] mlx4: Unicast Loopback support
Date: Wed, 10 Feb 2010 10:22:08 +0200
Message-ID: <15ddcffd1002100022gf9799f1u69864ed658b0b5ed@mail.gmail.com>
References: <49BFC313.1030901@mellanox.co.il> <4B6AEE18.1040104@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Roland Dreier <rdreier@cisco.com>, netdev@vger.kernel.org,
	liranl@mellanox.co.il, tziporet@mellanox.co.il
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:62233 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752872Ab0BJIWK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 03:22:10 -0500
Received: by bwz19 with SMTP id 19so1654192bwz.28
        for <netdev@vger.kernel.org>; Wed, 10 Feb 2010 00:22:08 -0800 (PST)
In-Reply-To: <4B6AEE18.1040104@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yevgeny Petrilin <yevgenyp@mellanox.co.il> wrote:
> All packets are subject to loopback.

I wasn't sure what is the use case here, isn't loopback handled by
higher levels at
the network stack?

Or.
