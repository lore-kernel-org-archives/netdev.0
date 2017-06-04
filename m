From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netxen: remove writeq/readq function definitions
Date: Sun, 04 Jun 2017 19:54:19 -0400 (EDT)
Message-ID: <20170604.195419.629224949993811105.davem@davemloft.net>
References: <20170602113627.28642-1-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: manish.chopra@cavium.com, rahul.verma@cavium.com,
        Dept-GELinuxNICDev@cavium.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: clabbe.montjoie@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52558 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751162AbdFDXyV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Jun 2017 19:54:21 -0400
In-Reply-To: <20170602113627.28642-1-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Corentin Labbe <clabbe.montjoie@gmail.com>
Date: Fri,  2 Jun 2017 13:36:27 +0200

> Instead of rewriting write/readq, use linux/io-64-nonatomic-lo-hi.h which
> already have them.
> 
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>

Applied to net-next.
