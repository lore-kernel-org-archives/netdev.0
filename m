From: Yotam Gigi <yotamg@mellanox.com>
Subject: RE: [PATCH net 0/2] Fix tc-ife bugs
Date: Sun, 25 Sep 2016 11:41:20 +0000
Message-ID: <DB3PR05MB07642C5019FDE949EF177DA0ACCA0@DB3PR05MB0764.eurprd05.prod.outlook.com>
References: <1474548926-22815-1-git-send-email-yotamg@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
To: "jhs@mojatatu.com" <jhs@mojatatu.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0079.outbound.protection.outlook.com ([104.47.2.79]:35179
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S936523AbcIYLlY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Sep 2016 07:41:24 -0400
In-Reply-To: <1474548926-22815-1-git-send-email-yotamg@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: Yotam Gigi
>Sent: Thursday, September 22, 2016 3:55 PM
>To: jhs@mojatatu.com; davem@davemloft.net; netdev@vger.kernel.org
>Cc: Yotam Gigi <yotamg@mellanox.com>
>Subject: [PATCH net 0/2] Fix tc-ife bugs
>
>This patch-set contains two bugfixes in the tc-ife action, one fixing some
>random behaviour in encode side, and one fixing the decode side packet
>parsing logic.

I have to rebase the patches. I will send v2 soon.

Thanks!

>
>Yotam Gigi (2):
>  act_ife: Fix external mac header on encode
>  act_ife: Fix false parsing on decode side
>
> net/sched/act_ife.c | 9 ++++-----
> 1 file changed, 4 insertions(+), 5 deletions(-)
>
>--
>2.4.11
