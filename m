From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next 3/3] mlx4_en: Saving mem access on data path
Date: Thu, 1 Mar 2012 15:03:02 +0200
Message-ID: <CAJZOPZ+Z-L4soSOnPxh68cEjeM6Pj8UBBnrmSwYf4VWyU_MA0Q@mail.gmail.com>
References: <4F464074.9050901@mellanox.co.il>
	<20120223.144749.1718133820851859801.davem@davemloft.net>
	<953B660C027164448AE903364AC447D2618B8782@MTLDAG02.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:51491 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S966168Ab2CANDE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2012 08:03:04 -0500
Received: by lahj13 with SMTP id j13so713335lah.19
        for <netdev@vger.kernel.org>; Thu, 01 Mar 2012 05:03:02 -0800 (PST)
In-Reply-To: <953B660C027164448AE903364AC447D2618B8782@MTLDAG02.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 24, 2012 at 9:57 PM, Yevgeny Petrilin <yevgenyp@mellanox.com> wrote:
> The patch set is a result of performance work we did, and those changes helped us
> to achieve better results without hurting us in other areas.


Hi Dave,

Following Yevgeny's clarification, can this patch (3/3) go to
net-next? as for patch 1/3, we
understand that the first thing to do in that area is add BQL support
to mlx4_en, makes sense.


Or.
