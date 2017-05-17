From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] bnxt_en: DCBX fixes.
Date: Wed, 17 May 2017 15:13:57 -0400 (EDT)
Message-ID: <20170517.151357.1284119876859401704.davem@davemloft.net>
References: <1494967184-12865-1-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: michael.chan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35728 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753838AbdEQTOJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 15:14:09 -0400
In-Reply-To: <1494967184-12865-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <michael.chan@broadcom.com>
Date: Tue, 16 May 2017 16:39:42 -0400

> 2 bug fixes for the case where the NIC's firmware DCBX agent is
> enabled.  With these fixes, we will return the proper information to
> lldpad.

Series applied, thanks Michael.
