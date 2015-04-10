From: Ian Jackson <Ian.Jackson@eu.citrix.com>
Subject: Re: tg3 NIC driver bug in 3.14.x under Xen [and 3 more messages]
Date: Fri, 10 Apr 2015 12:43:45 +0100
Message-ID: <21799.46961.634252.746670@mariner.uk.xensource.com>
References: <21795.62414.465476.464027@mariner.uk.xensource.com>
	<1428425741.4212.1.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	<21796.6843.983774.271495@mariner.uk.xensource.com>
	<21796.7755.270785.292996@mariner.uk.xensource.com>
	<1428448869.4212.2.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	<1428448976.4720.15.camel@prashant>
	<21797.13348.524963.29127@mariner.uk.xensource.com>
	<1428543798.4720.20.camel@prashant>
	<21798.24161.922394.539733@mariner.uk.xensource.com>
	<1428595851.4720.22.camel@prashant>
	<21798.44949.156680.399387@mariner.uk.xensource.com>
	<21798.46590.928152.666550@mariner.uk.xensource.com>
	<1428604015.5004.12.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Prashant Sreedharan <prashant@broadcom.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	"David Vrabel" <david.vrabel@citrix.com>,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	"Nithin Nayak Sujir" <nsujir@broadcom.com>,
	<xen-devel@lists.xensource.com>, <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:42889 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754708AbbDJLoN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 07:44:13 -0400
In-Reply-To: <1428604015.5004.12.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Chan writes ("Re: tg3 NIC driver bug in 3.14.x under Xen [and 3 more messages]"):
> Can you check to see if your kernel source has this tg3 patch applied?
> 
> tg3: Don't check undefined error bits in RXBD
> d7b95315cc7f441418845a165ee56df723941487

It does.

Ian.
