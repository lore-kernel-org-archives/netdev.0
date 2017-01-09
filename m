From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ibm: emac: use new api
 ethtool_{get|set}_link_ksettings
Date: Mon, 09 Jan 2017 12:10:40 -0500 (EST)
Message-ID: <20170109.121040.132495118475317544.davem@davemloft.net>
References: <1483824747-6405-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ivan@de.ibm.com, jarod@redhat.com, mugunthanvnm@ti.com,
        felipe.balbi@linux.intel.com, fw@strlen.de, mpe@ellerman.id.au,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42786 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1763131AbdAIRKn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 12:10:43 -0500
In-Reply-To: <1483824747-6405-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sat,  7 Jan 2017 22:32:27 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
