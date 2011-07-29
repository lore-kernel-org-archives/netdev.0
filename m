From: Rasesh Mody <rmody@brocade.com>
Subject: RE: [PATCH 1/2] bna: Remove Unnecessary CNA Check
Date: Thu, 28 Jul 2011 18:45:11 -0700
Message-ID: <E5313AF6F2BFD14293E5FD0F94750F86A83C0F0752@HQ1-EXCH01.corp.brocade.com>
References: <1311889767-9848-1-git-send-email-rmody@brocade.com>
 <20110728.182835.1135590491635663404.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Adapter Linux Open SRC Team"
	<adapter_linux_open_src_team@Brocade.COM>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:36368 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756293Ab1G2BpR convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jul 2011 21:45:17 -0400
In-Reply-To: <20110728.182835.1135590491635663404.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From: David Miller [mailto:davem@davemloft.net]
>Sent: Thursday, July 28, 2011 6:29 PM
>
>So are these bug fixes or cleanups/features?  You don't say where
>you intend these changes to go.

Can you please put these into net-next tree? These patches remove unnecessary code and updates h/w initialize code.

We'll submit the features/cleanups patches in subsequent submissions against net-next.

Thanks,
Rasesh
