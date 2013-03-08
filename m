From: Rasesh Mody <rmody@brocade.com>
Subject: RE: [PATCH net-next 1/5] bna: fix declaration mismatch
Date: Fri, 8 Mar 2013 11:30:18 -0800
Message-ID: <E5313AF6F2BFD14293E5FD0F94750F86B649F3A0D8@HQ1-EXCH01.corp.brocade.com>
References: <20130308190739.260966567@vyatta.com>
 <20130308190808.861866355@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:42178 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750851Ab3CHTaQ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Mar 2013 14:30:16 -0500
Received: from pps.filterd (m0000700 [127.0.0.1])
	by mx0b-000f0801.pphosted.com (8.14.5/8.14.5) with SMTP id r28JSWJG031173
	for <netdev@vger.kernel.org>; Fri, 8 Mar 2013 11:30:15 -0800
Received: from hq1wp-exchub02.corp.brocade.com ([144.49.131.13])
	by mx0b-000f0801.pphosted.com with ESMTP id 1ay7aw0d1y-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 08 Mar 2013 11:30:15 -0800
In-Reply-To: <20130308190808.861866355@vyatta.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From: Stephen Hemminger [mailto:shemminger@vyatta.com]
>Sent: Friday, March 08, 2013 11:08 AM
>
>The function is declared to take u32 but definition uses enum.
>
>Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

You are right, thanks Stephen!

Acked-by: Rasesh Mody <rmody@brocade.com>
