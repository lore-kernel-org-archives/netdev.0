From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] net sched actions: rename act_get_notify() to
 tcf_get_notify()
Date: Fri, 14 Jul 2017 08:52:47 -0700 (PDT)
Message-ID: <20170714.085247.1952535800711949061.davem@davemloft.net>
References: <1499965938-29679-1-git-send-email-mrv@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mrv@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36656 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751402AbdGNPwv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2017 11:52:51 -0400
In-Reply-To: <1499965938-29679-1-git-send-email-mrv@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roman Mashak <mrv@mojatatu.com>
Date: Thu, 13 Jul 2017 13:12:18 -0400

> Make name consistent with other TC event notification routines, such as
> tcf_add_notify() and tcf_del_notify()
> 
> Signed-off-by: Roman Mashak <mrv@mojatatu.com>

Applied.
