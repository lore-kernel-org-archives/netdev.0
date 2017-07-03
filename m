From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netxen_nic: Remove unused pointer hdr in
 netxen_setup_minidump()
Date: Mon, 03 Jul 2017 02:38:25 -0700 (PDT)
Message-ID: <20170703.023825.923807519793495955.davem@davemloft.net>
References: <1499033771-24820-1-git-send-email-chris.gekas@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: manish.chopra@cavium.com, rahul.verma@cavium.com,
        Dept-GELinuxNICDev@cavium.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: chris.gekas@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54948 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753902AbdGCJi2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2017 05:38:28 -0400
In-Reply-To: <1499033771-24820-1-git-send-email-chris.gekas@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christos Gkekas <chris.gekas@gmail.com>
Date: Sun,  2 Jul 2017 23:16:11 +0100

> Pointer hdr in netxen_setup_minidump() is set but never used, thus
> should be removed.
> 
> Signed-off-by: Christos Gkekas <chris.gekas@gmail.com>

Applied, thanks.
