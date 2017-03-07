From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/sched: act_skbmod: remove unneeded rcu_read_unlock
 in tcf_skbmod_dump
Date: Tue, 07 Mar 2017 14:13:52 -0800 (PST)
Message-ID: <20170307.141352.86084655936876518.davem@davemloft.net>
References: <f9a9b434-ea38-3f7f-6207-8c7bc7317bc4@mojatatu.com>
        <1488672115-11057-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: khoroshilov@ispras.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37816 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756150AbdCGWPb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Mar 2017 17:15:31 -0500
In-Reply-To: <1488672115-11057-1-git-send-email-khoroshilov@ispras.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Date: Sun,  5 Mar 2017 03:01:55 +0300

> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>

Applied and queued up for -stable, thanks.
