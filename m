From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] l2tp: drop l2tp_session_find()
Date: Tue, 11 Apr 2017 13:48:30 -0400 (EDT)
Message-ID: <20170411.134830.385476608301003006.davem@davemloft.net>
References: <cover.1491908878.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33958 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751620AbdDKRsd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 13:48:33 -0400
In-Reply-To: <cover.1491908878.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Tue, 11 Apr 2017 13:12:03 +0200

> l2tp_netlink is the last user of l2tp_session_find(), but that call is
> useless. Let's remove it and drop l2tp_session_find() definitely.

Series applied, thank you.
