From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ibmvnic: Free tx/rx scrq pointer array when
 releasing sub-crqs
Date: Thu, 16 Mar 2017 21:26:00 -0700 (PDT)
Message-ID: <20170316.212600.605844804302384979.davem@davemloft.net>
References: <20170316033807.13892.10840.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jallen@linux.vnet.ibm.com,
        tlfalcon@linux.vnet.ibm.com
To: nfont@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56140 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750970AbdCQE0y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Mar 2017 00:26:54 -0400
In-Reply-To: <20170316033807.13892.10840.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Date: Wed, 15 Mar 2017 23:38:07 -0400

> The pointer array for the tx/rx sub crqs should be free'ed when
> releasing the tx/rx sub crqs.
> 
> Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>

Applied, thanks.
