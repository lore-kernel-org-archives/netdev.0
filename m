From: Debashis Dutt <ddutt@Brocade.COM>
Subject: RE: Subject: [PATCH 1/6] bna: Brocade 10Gb Ethernet device driver
Date: Mon, 2 Nov 2009 19:14:20 -0800
Message-ID: <1B6CC3D5ACAB014C8BFB6CB1CBD62CADD2835E9830@HQ-EXCH-7.corp.brocade.com>
References: <200911010503.nA153Elp019063@blc-10-10.brocade.com>
	<1257053039.1917.147.camel@Joe-Laptop.home> <20091101112553.1dc0e3a9@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Rasesh Mody <rmody@brocade.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Adapter Linux Open SRC Team
	<adapter_linux_open_src_team@Brocade.COM>,
	Greg Kroah-Hartman <gregkh@suse.de>
To: Stephen Hemminger <shemminger@vyatta.com>,
	Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hq-exedge.brocade.com ([66.243.153.83]:37349 "EHLO
	hq-exedge.brocade.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756392AbZKCDOR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 22:14:17 -0500
In-Reply-To: <20091101112553.1dc0e3a9@nehalam>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen, 

This driver is written explicitly for Linux and we are working on addressing your
comments.

Please let us know, if we need to look at some other areas.

Thanks
--Debashis

-----Original Message-----
From: Stephen Hemminger [mailto:shemminger@vyatta.com] 
Sent: Sunday, November 01, 2009 11:26 AM
To: Joe Perches
Cc: Rasesh Mody; netdev@vger.kernel.org; Adapter Linux Open SRC Team; Greg Kroah-Hartman
Subject: Re: Subject: [PATCH 1/6] bna: Brocade 10Gb Ethernet device driver

On Sat, 31 Oct 2009 22:23:59 -0700
Joe Perches <joe@perches.com> wrote:

> There are an awful lot of non linux standard
> uses in this code set.
> 
> Perhaps staging would be a good place to start?
> 

Yup, it looks like a Windows driver port
