From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ip6_gre: ip6gre_tap device should keep dst
Date: Sun, 01 Oct 2017 03:54:56 +0100 (WEST)
Message-ID: <20171001.035456.1360694390405384824.davem@davemloft.net>
References: <0078656bd7917cd981210dfc89807a0728310b48.1506576230.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xeb@mail.ru
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33878 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750842AbdJACy5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 30 Sep 2017 22:54:57 -0400
In-Reply-To: <0078656bd7917cd981210dfc89807a0728310b48.1506576230.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Thu, 28 Sep 2017 13:23:50 +0800

> The patch 'ip_gre: ipgre_tap device should keep dst' fixed
> a issue that ipgre_tap mtu couldn't be updated in tx path.
> 
> The same fix is needed for ip6gre_tap as well.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied and queued up for -stable.
