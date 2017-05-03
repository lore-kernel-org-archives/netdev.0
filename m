From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next 00/11] ibmvnic: Updated reset handler and
 code fixes
Date: Wed, 03 May 2017 11:33:22 -0400 (EDT)
Message-ID: <20170503.113322.1558570812477364285.davem@davemloft.net>
References: <20170503180246.29742.64039.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brking@linux.vnet.ibm.com,
        jallen@linux.vnet.ibm.com, muvic@linux.vnet.ibm.com,
        tlfalcon@linux.vnet.ibm.com
To: nfont@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38408 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751795AbdECPdY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 11:33:24 -0400
In-Reply-To: <20170503180246.29742.64039.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Date: Wed, 03 May 2017 14:04:20 -0400

> This set of patches multiple code fixes and a new rest handler
> for the ibmvnic driver. In order to implement the new reset handler
> for the ibmvnic driver resource initialization needed to be moved to
> its own routine, a state variable is introduced to replace the
> various is_* flags in the driver, and a new routine to handle the
> assorted reasons the driver can be reset.

Series applied, thank you.
