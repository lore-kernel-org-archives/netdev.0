From: Rasesh Mody <rmody@brocade.com>
Subject: RE: [PATCH net-next] bnad: make local variable static
Date: Fri, 13 Dec 2013 17:34:23 -0800
Message-ID: <E5313AF6F2BFD14293E5FD0F94750F86B69010DFCD@HQ1-EXCH01.corp.brocade.com>
References: <20131213164010.0d082bbe@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:56823 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752649Ab3LNBe2 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Dec 2013 20:34:28 -0500
Received: from pps.filterd (m0000700 [127.0.0.1])
	by mx0b-000f0801.pphosted.com (8.14.5/8.14.5) with SMTP id rBE0lAgW031583
	for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 17:34:27 -0800
Received: from hq1wp-exchub01.corp.brocade.com ([144.49.131.13])
	by mx0b-000f0801.pphosted.com with ESMTP id 1gqse59a9f-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 17:34:27 -0800
In-Reply-To: <20131213164010.0d082bbe@nehalam.linuxnetplumber.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From: Stephen Hemminger [mailto:stephen@networkplumber.org]
>Sent: Friday, December 13, 2013 4:40 PM
>
>Compile tested only.

Thanks Stephen!

Sanity and basic traffic test conducted and it looks fine.

Acked-by: Rasesh Mody <rmody@brocade.com>
