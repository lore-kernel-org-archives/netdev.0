From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/7] ibmvnic: Cleanup resource handling
Date: Thu, 30 Mar 2017 15:58:59 -0700 (PDT)
Message-ID: <20170330.155859.565186902156028259.davem@davemloft.net>
References: <20170330064542.20309.17448.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jallen@linux.vnet.ibm.com,
        tlfalcon@linux.vnet.ibm.com
To: nfont@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36268 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932323AbdC3W7B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 18:59:01 -0400
In-Reply-To: <20170330064542.20309.17448.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Date: Thu, 30 Mar 2017 02:48:49 -0400

> In order to better manage the resources of the ibmvnic driver, this set of
> patches creates a set of initialization and release routines for the
> drivers resources. Additionally, some patches do some re-naming of the
> affected routines so that there is a common naming scheme in the driver.

Series applied to net-next.
