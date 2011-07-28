From: Rasesh Mody <rmody@brocade.com>
Subject: RE: [PATCH 0/8] bna: Driver Fixes and Support for Re-architecture
Date: Thu, 28 Jul 2011 12:30:51 -0700
Message-ID: <E5313AF6F2BFD14293E5FD0F94750F86A83C0F0623@HQ1-EXCH01.corp.brocade.com>
References: <1311732648-29876-1-git-send-email-rmody@brocade.com>
 <20110727.223231.1088299143542685793.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Adapter Linux Open SRC Team"
	<adapter_linux_open_src_team@Brocade.COM>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:47683 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754606Ab1G1TbM convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jul 2011 15:31:12 -0400
In-Reply-To: <20110727.223231.1088299143542685793.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From: David Miller [mailto:davem@davemloft.net]
>Sent: Wednesday, July 27, 2011 10:33 PM
>
>From: Rasesh Mody <rmody@brocade.com>
>Date: Tue, 26 Jul 2011 19:10:40 -0700
>
>>    This patch-set consists of few fixes, HW reg consolidation and adds
>support
>>    for re-architecture and re-organisation of the driver.
>
>Please do not mix bug fixes and feature changes.
>
>If you do this, I can't put the bug fixes into the current release.
>
>Seperate out the real pure bug fixes into a seperate series against
>the main 'net' GIT tree.
>
>Then you can submit your feature changes and cleanups seperately for
>'net-next'

We will submit the bug fixes and the feature changes separately.
Thanks,
Rasesh
