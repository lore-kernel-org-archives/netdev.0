From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next repost] nfp: add VLAN filtering support
Date: Mon, 19 Jun 2017 00:12:05 -0400 (EDT)
Message-ID: <20170619.001205.795471539180645122.davem@davemloft.net>
References: <20170615232215.20073-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        pablo.cascon@netronome.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44698 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750790AbdFSEMI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 00:12:08 -0400
In-Reply-To: <20170615232215.20073-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Thu, 15 Jun 2017 16:22:15 -0700

> From: Pablo Cascón <pablo.cascon@netronome.com>
> 
> Add general use per-vNIC mailbox area and use it for VLAN filtering
> support.  Initially proto is hardcoded to 802.1q.
> 
> Signed-off-by: Pablo Cascón <pablo.cascon@netronome.com>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Applied.
