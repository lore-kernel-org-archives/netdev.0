From: "Majumder, Rajib" <rajib.majumder@credit-suisse.com>
Subject: TCP ACK
Date: Thu, 24 Aug 2006 23:03:22 +0800
Message-ID: <F444CAE5E62A714C9F45AA292785BED30EB97453@esng11p33001.sg.csfb.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from ny-bas08.csfb.com ([198.240.130.81]:25816 "EHLO
	ny-bas08.csfb.com") by vger.kernel.org with ESMTP id S1751594AbWHXPDi
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Aug 2006 11:03:38 -0400
Received: from snyc11p30740.csfb.cs-group.com (snyc11p30740.csfb.mail [169.37.102.102])
	by ny-bas08.csfb.com (Postfix) with ESMTP id 9AB8C179E
	for <netdev@vger.kernel.org>; Thu, 24 Aug 2006 11:03:27 -0400 (EDT)
To: "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I had a fundamental question regarding stack. When does TCP ack a segment? Is it immediately receiving a segment or after copying the data from kernel to user i.e after read() system call returns?

Any input is highly appreciated. 

Thanks

Rajib

==============================================================================
Please access the attached hyperlink for an important electronic communications disclaimer: 

http://www.credit-suisse.com/legal/en/disclaimer_email_ib.html
==============================================================================

