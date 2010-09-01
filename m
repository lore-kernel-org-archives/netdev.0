From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pxa168_eth: fix a mdiobus leak
Date: Wed, 01 Sep 2010 14:30:17 -0700 (PDT)
Message-ID: <20100901.143017.257520937.davem@davemloft.net>
References: <20100830072138.GA8797@hera.kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: error27@gmail.com, ssanap@marvell.com, netdev@vger.kernel.org
To: dkirjanov@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50447
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754161Ab0IAVaB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 17:30:01 -0400
In-Reply-To: <20100830072138.GA8797@hera.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denis Kirjanov <dkirjanov@kernel.org>
Date: Mon, 30 Aug 2010 07:21:38 +0000

> mdiobus resources must be released on exit
> Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>

Applied.
