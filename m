From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] ibmvnic: Tunable parameter support
Date: Sun, 22 Oct 2017 03:16:29 +0100 (WEST)
Message-ID: <20171022.031629.1461545210725781058.davem@davemloft.net>
References: <9bafaca4-75e7-ba82-8eea-35a69c61b6db@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tlfalcon@linux.vnet.ibm.com,
        nfont@linux.vnet.ibm.com
To: jallen@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57720 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932325AbdJVCQe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Oct 2017 22:16:34 -0400
In-Reply-To: <9bafaca4-75e7-ba82-8eea-35a69c61b6db@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Allen <jallen@linux.vnet.ibm.com>
Date: Fri, 20 Oct 2017 16:00:54 -0500

> This series implements support for changing tunable parameters such as the
> mtu, number of tx/rx queues, and number of buffers per queue via ethtool
> and ifconfig.

These patches do not apply to net-next.
