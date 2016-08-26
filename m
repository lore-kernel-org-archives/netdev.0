From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] veth: sctp: add NETIF_F_SCTP_CRC to device features
Date: Fri, 26 Aug 2016 11:43:38 -0700 (PDT)
Message-ID: <20160826.114338.1613853981669207386.davem@davemloft.net>
References: <3b9880c091c96f4e6780b96b4f3e2c4d38dffe42.1472102509.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, vyasevich@gmail.com,
        daniel@iogearbox.net
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59582 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751014AbcHZSnj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 14:43:39 -0400
In-Reply-To: <3b9880c091c96f4e6780b96b4f3e2c4d38dffe42.1472102509.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Thu, 25 Aug 2016 13:21:49 +0800

> Commit b17c706987fa ("loopback: sctp: add NETIF_F_SCTP_CSUM to device
> features") added NETIF_F_SCTP_CRC to device features for lo device to
> improve the performance of sctp over lo.
> 
> This patch is to add NETIF_F_SCTP_CRC to device features for veth to
> improve the performance of sctp over veth.
 ...
> Tested-by: Li Shuang <tjlishuang@yeah.net>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied to net-next, thanks.
