From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnxt: Move generic devlink code to new file
Date: Sat, 21 Oct 2017 12:28:51 +0100 (WEST)
Message-ID: <20171021.122851.738926339314125960.davem@davemloft.net>
References: <1508424356-24619-1-git-send-email-steven.lin1@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, michael.chan@broadcom.com,
        gospo@broadcom.com
To: steven.lin1@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50592 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932076AbdJUL2z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Oct 2017 07:28:55 -0400
In-Reply-To: <1508424356-24619-1-git-send-email-steven.lin1@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Lin <steven.lin1@broadcom.com>
Date: Thu, 19 Oct 2017 10:45:56 -0400

> Moving generic devlink code (registration) out of VF-R code
> into new bnxt_devlink file, in preparation for future work
> to add additional devlink functionality to bnxt.
> 
> Signed-off-by: Steve Lin <steven.lin1@broadcom.com>
> Acked-by: Andy Gospodarek <gospo@broadcom.com>

Applied.
