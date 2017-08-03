From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: fix the printing of ifindex
Date: Thu, 03 Aug 2017 09:25:48 -0700 (PDT)
Message-ID: <20170803.092548.1194723615948384850.davem@davemloft.net>
References: <1501688632-2709-1-git-send-email-u9012063@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: u9012063@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45084 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751144AbdHCQZs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 12:25:48 -0400
In-Reply-To: <1501688632-2709-1-git-send-email-u9012063@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: William Tu <u9012063@gmail.com>
Date: Wed,  2 Aug 2017 08:43:52 -0700

> Save the ifindex before it gets zeroed so the invalid
> ifindex can be printed out.
> 
> Signed-off-by: William Tu <u9012063@gmail.com>

Applied, thanks.
