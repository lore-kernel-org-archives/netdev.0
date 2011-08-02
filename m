From: Rasesh Mody <rmody@brocade.com>
Subject: RE: [PATCH 6/6] bna: Tx and Rx Redesign
Date: Tue, 2 Aug 2011 11:05:02 -0700
Message-ID: <E5313AF6F2BFD14293E5FD0F94750F86A83C0F0CE7@HQ1-EXCH01.corp.brocade.com>
References: <1312231375-14398-1-git-send-email-rmody@brocade.com>
	<1312231375-14398-7-git-send-email-rmody@brocade.com>
 <20110801.180959.434819216427342007.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Adapter Linux Open SRC Team"
	<adapter_linux_open_src_team@Brocade.COM>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:56825 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753348Ab1HBSFK convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2011 14:05:10 -0400
In-Reply-To: <20110801.180959.434819216427342007.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From: David Miller [mailto:davem@davemloft.net]
>Sent: Monday, August 01, 2011 6:10 PM
>
>This just adds a lot of new code, but there are no users of this
>new code.
>
>Resubmit this when you have the actual users of the code ready.

We took this approach to avoid sending large amount of patches at once while keeping the patches bisectable.

We can resubmit the first 3 patches as enhancements and submit new code in a separate patch set with actual user of the code, but the patch count may be little high for this new code enablement, is this ok?

Thanks,
Rasesh
