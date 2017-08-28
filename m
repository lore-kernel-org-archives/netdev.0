From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/11] bnxt_en: Updates.
Date: Mon, 28 Aug 2017 16:57:23 -0700 (PDT)
Message-ID: <20170828.165723.1607285320294641144.davem@davemloft.net>
References: <1503942035-24924-1-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: michael.chan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51670 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751194AbdH1X5Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 19:57:24 -0400
In-Reply-To: <1503942035-24924-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <michael.chan@broadcom.com>
Date: Mon, 28 Aug 2017 13:40:24 -0400

> Various changes including updated firmware interface, improved TX ring
> allocation scheme, improved out-of-memory logic in NAPI loop, reduced
> default rings on multi-port devices, new PCI IDs. Of particular note,
> 
> CPU affinity hints from Vasundhara Volam.
> 
> TC Flower eswitch support from Sathya Perla.

Looks good, series applied, thanks!
