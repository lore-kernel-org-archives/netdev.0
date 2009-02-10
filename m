From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v2 net-next] Re: can't add tc multiq
Date: Tue, 10 Feb 2009 11:57:43 +0000
Message-ID: <20090210115743.GB14808@ff.dom.local>
References: <20090209081553.4a874433@extreme> <20090209214446.GA2542@ami.dom.local> <20090209144052.6636f069@extreme> <20090210074154.GA4190@ff.dom.local> <49916554.3040201@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.185]:26180 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751252AbZBJL5v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2009 06:57:51 -0500
Received: by fk-out-0910.google.com with SMTP id f33so1778184fkf.5
        for <netdev@vger.kernel.org>; Tue, 10 Feb 2009 03:57:48 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <49916554.3040201@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 10, 2009 at 02:30:28PM +0300, Badalian Vyacheslav wrote:
> Thanks all! i will go to buy e1000e.

Try to grep in drivers/net for 'alloc_etherdev_mq' to find multiqueue
NICs/drivers.

Jarek P.
