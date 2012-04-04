From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tilepro ethernet driver: fix a few minor issues
Date: Wed, 04 Apr 2012 17:44:51 -0400 (EDT)
Message-ID: <20120404.174451.1247414877210242753.davem@davemloft.net>
References: <201203302325.q2UNPm8j012403@farm-0012.internal.tilera.com>
	<20120403.182335.782073108961783777.davem@davemloft.net>
	<4F7C3C00.5020105@tilera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: cmetcalf@tilera.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F7C3C00.5020105@tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Metcalf <cmetcalf@tilera.com>
Date: Wed, 4 Apr 2012 08:18:08 -0400

> It didn't occur to me that you would push it through the net tree; I
> assumed I would push it through the tile tree.

If it's purely changes inside the networking driver, best to push
it through the networking tree(s).
