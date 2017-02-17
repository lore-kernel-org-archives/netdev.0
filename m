From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] tcp: accommodate sequence number to a peer's
 shrunk receive window caused by precision loss in window scaling
Date: Fri, 17 Feb 2017 11:52:49 -0500 (EST)
Message-ID: <20170217.115249.559493969225896515.davem@davemloft.net>
References: <41B57547-A148-49D5-8F03-18F976263CED@netapp.com>
        <20170217.110858.1023681409351044871.davem@davemloft.net>
        <1554418B-B544-4F08-84D2-0FFF5AEAAF84@netapp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net
To: Cheng.Cui@netapp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45458 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934140AbdBQQwx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 11:52:53 -0500
In-Reply-To: <1554418B-B544-4F08-84D2-0FFF5AEAAF84@netapp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Cui, Cheng" <Cheng.Cui@netapp.com>
Date: Fri, 17 Feb 2017 16:44:23 +0000

> Thanks for the comment. This is the patch update.

Please make the commit message proper, as it was in your initial posting,
explaining what you are doing and how.

Don't make it part of your dialogue with the reviewers.
