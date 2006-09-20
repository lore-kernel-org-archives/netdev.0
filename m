From: "Majumder, Rajib" <rajib.majumder@credit-suisse.com>
Subject: UDP Out 0f Sequence
Date: Wed, 20 Sep 2006 15:13:48 +0800
Message-ID: <F444CAE5E62A714C9F45AA292785BED30EB97591@esng11p33001.sg.csfb.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from ny-bas08.csfb.com ([198.240.130.81]:44774 "EHLO
	ny-bas08.csfb.com") by vger.kernel.org with ESMTP id S1751020AbWITHQ1
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Sep 2006 03:16:27 -0400
Received: from snyc11p30741.csfb.cs-group.com (snyc11p30741.csfb.mail [169.37.102.72])
	by ny-bas08.csfb.com (Postfix) with ESMTP id 88F6C1821
	for <netdev@vger.kernel.org>; Wed, 20 Sep 2006 03:16:26 -0400 (EDT)
To: "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

If I write UDP datagrams 1,2 and 3 to network and if the receiver receives in order 2,1, and 3, where can the sequence get changed? Is it at the source stack, network transit or destination stack? 

Any reply is highly appreciated. 

Thanks

Rajib 

==============================================================================
Please access the attached hyperlink for an important electronic communications disclaimer: 

http://www.credit-suisse.com/legal/en/disclaimer_email_ib.html
==============================================================================

