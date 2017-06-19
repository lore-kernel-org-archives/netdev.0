From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/7] qed*: RDMA and infrastructure for iWARP
Date: Sun, 18 Jun 2017 21:40:41 -0400 (EDT)
Message-ID: <20170618.214041.682320908274865753.davem@davemloft.net>
References: <20170618115035.2156-1-Yuval.Mintz@cavium.com>
        <20170618.122901.124548969151925362.davem@davemloft.net>
        <BLUPR0701MB20047CD16002072436A61EA38DC70@BLUPR0701MB2004.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Michal.Kalderon@cavium.com,
        linux-rdma@vger.kernel.org
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41888 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753236AbdFSBkp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Jun 2017 21:40:45 -0400
In-Reply-To: <BLUPR0701MB20047CD16002072436A61EA38DC70@BLUPR0701MB2004.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Date: Sun, 18 Jun 2017 17:54:49 +0000

> I can't really say I understand who would benefit from adding "while
> at it remove redundant inclusion of header file" to the commit log
> message [And even less from splitting this into its own patch].

Because it helps people understand why you are making a change.

It's not obvious from just reading it.

That's why.
