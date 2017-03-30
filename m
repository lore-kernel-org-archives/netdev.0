From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ibmvnic: Remove debugfs support
Date: Thu, 30 Mar 2017 12:41:28 -0700 (PDT)
Message-ID: <20170330.124128.227321056161001441.davem@davemloft.net>
References: <20170329191445.56113.91288.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jallen@linux.vnet.ibm.com,
        tlfalcon@linux.vnet.ibm.com
To: nfont@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34264 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934091AbdC3Tla (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 15:41:30 -0400
In-Reply-To: <20170329191445.56113.91288.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Date: Wed, 29 Mar 2017 15:14:55 -0400

> The debugfs support in the ibmvnic driver is not, and never has been,
> supported. Just remove it.
> 
> The work done in the debugfs code for the driver was part of the original
> spec for the ibmvnic driver. The corresponding support for this from the
> server side was never supported and has been dropped.
> 
> Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>

Applied to net-next, thanks.
