From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] bnxt_en: bug fixes.
Date: Wed, 23 Aug 2017 22:42:59 -0700 (PDT)
Message-ID: <20170823.224259.2059066000444207596.davem@davemloft.net>
References: <1503531245-4046-1-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: michael.chan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:32780 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751019AbdHXFm7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 01:42:59 -0400
In-Reply-To: <1503531245-4046-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <michael.chan@broadcom.com>
Date: Wed, 23 Aug 2017 19:34:02 -0400

> 3 bug fixes related to XDP ring accounting in bnxt_setup_tc(), freeing
> MSIX vectors when bnxt_re unregisters, and preserving the user-administered
> PF MAC address when disabling SRIOV.

Series applied, thanks.
