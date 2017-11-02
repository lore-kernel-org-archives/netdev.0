From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] net: dpaa: two minor cleanup
Date: Thu, 02 Nov 2017 16:15:41 +0900 (KST)
Message-ID: <20171102.161541.712626275509980367.davem@davemloft.net>
References: <1509541790-16068-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Linyu.Yuan@alcatel-sbell.com.cn
To: cugyly@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44212 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755155AbdKBHPo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2017 03:15:44 -0400
In-Reply-To: <1509541790-16068-1-git-send-email-cugyly@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <cugyly@163.com>
Date: Wed,  1 Nov 2017 21:09:50 +0800

> From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
> 
> original i try to remove duplicate code which clean allocated per-cpu area,
> thanks to David S. Miller, there are two build warning as errors.
> path 1: fix old code maybe-uninitialized warning.
> path 2: remove duplicate code and fix unused var warning.

Series applied, thank you.
