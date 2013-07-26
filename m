From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net/tg3: Fix warning from pci_disable_device()
Date: Fri, 26 Jul 2013 14:28:52 -0700 (PDT)
Message-ID: <20130726.142852.736320857031123666.davem@davemloft.net>
References: <1374657909-26929-1-git-send-email-shangw@linux.vnet.ibm.com>
	<1374657909-26929-2-git-send-email-shangw@linux.vnet.ibm.com>
	<51EFC830.9080801@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shangw@linux.vnet.ibm.com, netdev@vger.kernel.org,
	mchan@broadcom.com
To: nsujir@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37787 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932789Ab3GZV2w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 17:28:52 -0400
In-Reply-To: <51EFC830.9080801@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Date: Wed, 24 Jul 2013 05:27:28 -0700

> On 7/24/2013 2:25 AM, Gavin Shan wrote:
>> The patch fixes following warning. The PCI device might have been
>> disabled somewhere else when we have EEH errors during early stage.
 ...
>> Reported-by: Wei Yang <weiyang@linux.vnet.ibm.com>
>> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
 ...
> Acked-by: Nithin Nayak Sujir <nsujir@broadcom.com>

Applied.
