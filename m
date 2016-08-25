From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/2] net: diag: slightly refactor the
 inet_diag_bc_audit error checks.
Date: Wed, 24 Aug 2016 21:57:31 -0700 (PDT)
Message-ID: <20160824.215731.783293603505126999.davem@davemloft.net>
References: <1472021186-4106-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
        dsa@cumulusnetworks.com, ek@google.com
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38275 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751506AbcHYE5i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 00:57:38 -0400
In-Reply-To: <1472021186-4106-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Wed, 24 Aug 2016 15:46:25 +0900

> This simplifies the code a bit and also allows inet_diag_bc_audit
> to send to userspace an error that isn't EINVAL.
> 
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>

Applied.
