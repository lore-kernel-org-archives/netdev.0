From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: [PATCH v2 net-next] Re: can't add tc multiq
Date: Tue, 10 Feb 2009 15:07:23 +0300
Message-ID: <49916DFB.7060900@bigtelecom.ru>
References: <20090209081553.4a874433@extreme> <20090209214446.GA2542@ami.dom.local> <20090209144052.6636f069@extreme> <20090210074154.GA4190@ff.dom.local> <49916554.3040201@bigtelecom.ru> <20090210115743.GB14808@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:40792 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750887AbZBJMH2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2009 07:07:28 -0500
In-Reply-To: <20090210115743.GB14808@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ohh... so small. e1000 and e1000e not have hw queues in life or its
simple not have implementation in driver?
Thanks again and again!

> On Tue, Feb 10, 2009 at 02:30:28PM +0300, Badalian Vyacheslav wrote:
>   
>> Thanks all! i will go to buy e1000e.
>>     
>
> Try to grep in drivers/net for 'alloc_etherdev_mq' to find multiqueue
> NICs/drivers.
>
> Jarek P.
>
>   

