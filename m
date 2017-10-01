From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ibmvnic: Set state UP
Date: Sun, 01 Oct 2017 04:03:00 +0100 (WEST)
Message-ID: <20171001.040300.1049787845412586313.davem@davemloft.net>
References: <1506631998-12670-1-git-send-email-mjtarsel@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tlfalcon@linux.vnet.ibm.com
To: mjtarsel@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34046 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751036AbdJADDB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 30 Sep 2017 23:03:01 -0400
In-Reply-To: <1506631998-12670-1-git-send-email-mjtarsel@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mick Tarsel <mjtarsel@linux.vnet.ibm.com>
Date: Thu, 28 Sep 2017 13:53:18 -0700

> State is initially reported as UNKNOWN. Before register call
> netif_carrier_off(). Once the device is opened, call netif_carrier_on() in
> order to set the state to UP.
> 
> Signed-off-by: Mick Tarsel <mjtarsel@linux.vnet.ibm.com>

Applied.
