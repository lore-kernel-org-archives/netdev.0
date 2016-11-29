From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: arc_emac: add dependencies on associated arches
 and compile test
Date: Tue, 29 Nov 2016 18:57:57 -0500 (EST)
Message-ID: <20161129.185757.897468314817275149.davem@davemloft.net>
References: <20161128071237.9016-1-pbrobinson@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zhengxing@rock-chips.com, al.kochet@gmail.com, tremyfr@gmail.com,
        netdev@vger.kernel.org
To: pbrobinson@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36546 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754592AbcK2X6C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 18:58:02 -0500
In-Reply-To: <20161128071237.9016-1-pbrobinson@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Robinson <pbrobinson@gmail.com>
Date: Mon, 28 Nov 2016 07:12:37 +0000

> Add dependencies on the architectures that support these devices and
> add compile test to ensure ongoing code build coverage.
> 
> Signed-off-by: Peter Robinson <pbrobinson@gmail.com>

Applied.
