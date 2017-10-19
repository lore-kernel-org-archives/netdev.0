From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] ibmvnic: Enable SG and TSO feature support
Date: Thu, 19 Oct 2017 13:20:47 +0100 (WEST)
Message-ID: <20171019.132047.246984013119139524.davem@davemloft.net>
References: <1508261816-3145-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tlfalcon@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48932 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751937AbdJSMUw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 08:20:52 -0400
In-Reply-To: <1508261816-3145-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Date: Tue, 17 Oct 2017 12:36:53 -0500

> This patch set is fairly straightforward. The first patch enables
> scatter-gather support in the ibmvnic driver. The following patch
> then enables the TCP Segmentation offload feature. The final patch 
> allows users to enable or disable net device features using ethtool.
> 
> Enabling SG and TSO grants a large increase in throughput with TX
> speed increasing from 1Gb/s to 9Gb/s in our initial test runs.

Series applied.
