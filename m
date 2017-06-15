From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5 net-next] ibmvnic: Activate disabled RX buffer
 pools on reset
Date: Wed, 14 Jun 2017 23:42:04 -0400 (EDT)
Message-ID: <20170614.234204.669779876622082650.davem@davemloft.net>
References: <1497497748-14075-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nfont@linux.vnet.ibm.com,
        jallen@linux.vnet.ibm.com
To: tlfalcon@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37734 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751555AbdFODmH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 23:42:07 -0400
In-Reply-To: <1497497748-14075-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please always provide a proper "[PATCH 0/N ...] " header posting
explaining what the patch series is doing, how it is doing it, and why
it is doing it that way.

I am getting kind of tired asking people for this FWIW...
