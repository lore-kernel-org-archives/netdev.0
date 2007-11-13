From: Pierre Ynard <linkfanel@yahoo.fr>
Subject: Re : [PATCH][IPv6] Add ifindex field in ND user option messages
Date: Tue, 13 Nov 2007 01:08:26 +0000 (GMT)
Message-ID: <225828.70511.qm@web25704.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	rdenis@simphalempin.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web25704.mail.ukl.yahoo.com ([217.12.10.176]:31212 "HELO
	web25704.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755100AbXKMBPK convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Nov 2007 20:15:10 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Unfortunately you cannot change the layout of a structure
> already exported to userspace, it is part of the ABI.

Well, I thought it would not be a problem, as it is not exactly
released yet. We are also currently developping the
corresponding RDNSS daemon and would be totally ready to
handle this change :)

-- 
Pierre Ynard





      _____________________________________________________________________________ 
Ne gardez plus qu'une seule adresse mail ! Copiez vos mails vers Yahoo! Mail 
