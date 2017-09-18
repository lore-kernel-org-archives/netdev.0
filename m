From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH] bnxt_en: check for ingress qdisc in flower offload
Date: Mon, 18 Sep 2017 16:52:39 -0700 (PDT)
Message-ID: <20170918.165239.1980314273212352581.davem@davemloft.net>
References: <1505734537-6695-1-git-send-email-sathya.perla@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, michael.chan@broadcom.com
To: sathya.perla@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59106 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751034AbdIRXwk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 19:52:40 -0400
In-Reply-To: <1505734537-6695-1-git-send-email-sathya.perla@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@broadcom.com>
Date: Mon, 18 Sep 2017 17:05:37 +0530

> Check for ingress-only qdisc for flower offload, as other qdiscs
> are not supported for flower offload.
> 
> Suggested-by: Jiri Pirko <jiri@resnulli.us>
> Signed-off-by: Sathya Perla <sathya.perla@broadcom.com>

Applied, thanks.
