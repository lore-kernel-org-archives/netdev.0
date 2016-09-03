From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V5 0/8] liquidio CN23XX support
Date: Fri, 02 Sep 2016 17:12:37 -0700 (PDT)
Message-ID: <20160902.171237.358859803073797674.davem@davemloft.net>
References: <1472753771-21141-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rvatsavayi@caviumnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59336 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751691AbcICAMj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 20:12:39 -0400
In-Reply-To: <1472753771-21141-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Date: Thu, 1 Sep 2016 11:16:03 -0700

> I am posting the remaining half of patchset after the
> acceptance of first half. With this patchset I am able
> to completely submit the code of V3 patchset  which you
> earlier advised me to split into smaller ones.
> 
> This V5 patch also addresses all the comments from previous
> submission:
> 1) Avoid busy loop while reading registers.
> 2) Other minor comments about debug messages and constants.
> 
> Please apply patches in following order as some of the
> patches depend on earlier patches.

Series applied.
