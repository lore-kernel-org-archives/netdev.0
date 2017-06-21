From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ibmvnic: Correct return code checking for
 ibmvnic_init during probe
Date: Wed, 21 Jun 2017 15:52:31 -0400 (EDT)
Message-ID: <20170621.155231.2270998903029219794.davem@davemloft.net>
References: <20170620212154.46216.80460.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
        <20170621.153936.1668683376357645391.davem@davemloft.net>
        <199365a2-50ce-1d16-8192-0eb4157c215f@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jallen@linux.vnet.ibm.com,
        tlfalcon@linux.vnet.ibm.com
To: nfont@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44704 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751038AbdFUTwd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 15:52:33 -0400
In-Reply-To: <199365a2-50ce-1d16-8192-0eb4157c215f@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Date: Wed, 21 Jun 2017 14:48:06 -0500

> On 06/21/2017 02:39 PM, David Miller wrote:
>> From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
>> Date: Tue, 20 Jun 2017 17:21:54 -0400
>> 
>>> Fixes: 6a2fb0e99f9c (ibmvnic: driver initialization for kdump/kexec)
>> 
>> I'm incredibly curious where you got the idea to put the Fixes: tag
>> at the beginning of the commit message.
> 
> I have no excuse. As you mentioned I should have looked at what others
> had done when using the Fixes.
> 
> Would you like me to re-send with the Fixes tag corrected?

Yes, please.
