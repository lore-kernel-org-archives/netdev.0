From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] bnxt_en: Updates for net-next.
Date: Mon, 24 Apr 2017 13:55:37 -0400 (EDT)
Message-ID: <20170424.135537.78941480159717218.davem@davemloft.net>
References: <1492819886-19625-1-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: michael.chan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55368 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S974810AbdDXRzj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 13:55:39 -0400
In-Reply-To: <1492819886-19625-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <michael.chan@broadcom.com>
Date: Fri, 21 Apr 2017 20:11:21 -0400

> Miscellaneous updates include passing DCBX RoCE VLAN priority to firmware,
> checking one more new firmware flag before allowing DCBX to run on the host,
> adding 100Gbps speed support, adding check to disallow speed settings on
> Multi-host NICs, and a minor fix for reporting VF attributes.

Series applied, thanks.
