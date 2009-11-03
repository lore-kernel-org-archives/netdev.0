From: Rasesh Mody <rmody@brocade.com>
Subject: RE: Subject: [PATCH 1/6] bna: Brocade 10Gb Ethernet device driver
Date: Tue, 3 Nov 2009 10:24:41 -0800
Message-ID: <CBE1CC7A31453F4CA63C13EFCE6A0F6C05BAC64093@HQ-EXCH-7.corp.brocade.com>
References: <200911010503.nA153Elp019063@blc-10-10.brocade.com>
 <1257053039.1917.147.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Adapter Linux Open SRC Team"
	<adapter_linux_open_src_team@Brocade.COM>,
	Greg Kroah-Hartman <gregkh@suse.de>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hq-exedge.brocade.com ([66.243.153.82]:54568 "EHLO
	hq-exedge.brocade.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750838AbZKCSYj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 13:24:39 -0500
In-Reply-To: <1257053039.1917.147.camel@Joe-Laptop.home>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe,
Thanks for your input. We are in the process addressing the comments that we are getting.

Can you please give examples or elaborate your comment? It would be really helpful.
Thanks,
-- Rasesh

-----Original Message-----
From: Joe Perches [mailto:joe@perches.com] 
Sent: Saturday, October 31, 2009 10:24 PM
To: Rasesh Mody
Cc: netdev@vger.kernel.org; Adapter Linux Open SRC Team; Greg Kroah-Hartman
Subject: Re: Subject: [PATCH 1/6] bna: Brocade 10Gb Ethernet device driver

There are an awful lot of non linux standard
uses in this code set.

Perhaps staging would be a good place to start?

