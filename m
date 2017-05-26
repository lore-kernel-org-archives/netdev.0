From: yuan linyu <cugyly@163.com>
Subject: [PATCH net-next 0/2] ndisc.c minor clean and improvement
Date: Fri, 26 May 2017 21:21:31 +0800
Message-ID: <1495804891-2828-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Joe Perches <joe@perches.com>, David Ahern <dsahern@gmail.com>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-13.163.com ([220.181.12.13]:49061 "EHLO m12-13.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751746AbdEZNWV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 26 May 2017 09:22:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

1. fix part of checkpatch issue which I like to fix
2. __ndisc_fill_addr_option() clean

yuan linyu (2):
  net: ndisc.c: fix coding style issue
  net: ndisc.c: minor code improvement

 net/ipv6/ndisc.c | 139 ++++++++++++++++++++++++++++---------------------------
 1 file changed, 70 insertions(+), 69 deletions(-)

-- 
2.7.4
