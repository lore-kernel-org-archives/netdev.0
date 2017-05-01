From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 10/11] From: Thomas Falcon
 <tlfalcon@linux.vnet.ibm.com>
Date: Mon, 01 May 2017 14:27:49 -0400 (EDT)
Message-ID: <20170501.142749.70498074494376481.davem@davemloft.net>
References: <20170501215424.27224.53918.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
        <20170501215737.27224.47900.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brking@linux.vnet.ibm.com,
        jallen@linux.vnet.ibm.com, muvic@linux.vnet.ibm.com,
        tlfalcon@linux.vnet.ibm.com
To: nfont@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35716 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750743AbdEAS1x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 14:27:53 -0400
In-Reply-To: <20170501215737.27224.47900.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Date: Mon, 01 May 2017 17:57:37 -0400

> From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
> 
> ibmvnic: Record SKB RX queue during poll
> 
> Map each RX SKB to the RX queue associated with the driver's RX SCRQ.
> This should improve the RX CPU load balancing issues seen by the
> performance team.
> 
> Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>

Please resend this series, this subject line is not correct.
