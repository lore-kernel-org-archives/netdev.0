From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ibmvnic: Correct return code checking for
 ibmvnic_init during probe
Date: Wed, 21 Jun 2017 15:39:36 -0400 (EDT)
Message-ID: <20170621.153936.1668683376357645391.davem@davemloft.net>
References: <20170620212154.46216.80460.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jallen@linux.vnet.ibm.com,
        tlfalcon@linux.vnet.ibm.com
To: nfont@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44468 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751038AbdFUTji (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 15:39:38 -0400
In-Reply-To: <20170620212154.46216.80460.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Date: Tue, 20 Jun 2017 17:21:54 -0400

> Fixes: 6a2fb0e99f9c (ibmvnic: driver initialization for kdump/kexec)

I'm incredibly curious where you got the idea to put the Fixes: tag
at the beginning of the commit message.

Have you seen anyone else submitting patches on netdev do this?

It helps to operate by example, and look at how other people do
things.

The correct location for the Fixes: tag is at the beginning of the
singoffs and acks at the end of the commit message.

There shall be no empty lines between the Fixes: tag and those
signoffs and acks.

Thank you.
