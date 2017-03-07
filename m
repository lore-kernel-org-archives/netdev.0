From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/7] bnx2x: PTP crash, VF VLAN fixes
Date: Tue, 07 Mar 2017 13:53:46 -0800 (PST)
Message-ID: <20170307.135346.1250571899354340182.davem@davemloft.net>
References: <20170303160834.4125-1-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yuval.Mintz@cavium.com,
        ariel.elior@cavium.com
To: mschmidt@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38944 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756592AbdCGXtx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Mar 2017 18:49:53 -0500
In-Reply-To: <20170303160834.4125-1-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Schmidt <mschmidt@redhat.com>
Date: Fri,  3 Mar 2017 17:08:27 +0100

> here are fixes for a crash with PTP, a crash in setting of VF multicast
> addresses, and non-working VLAN filters configuration from the VF side.

Series applied, thanks.
