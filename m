From: Pierre Ynard <linkfanel@yahoo.fr>
Subject: Re : Re : [PATCH][IPv6] Add ifindex field in ND user option messages
Date: Tue, 13 Nov 2007 01:19:47 +0000 (GMT)
Message-ID: <195892.80996.qm@web25711.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	rdenis@simphalempin.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web25711.mail.ukl.yahoo.com ([217.12.10.53]:34199 "HELO
	web25711.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753774AbXKMBTs convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Nov 2007 20:19:48 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > > Unfortunately you cannot change the layout of a structure
> > > already exported to userspace, it is part of the ABI.
> > 
> > Well, I thought it would not be a problem, as it is not exactly
> > released yet. We are also currently developping the
> > corresponding RDNSS daemon and would be totally ready to
> > handle this change :)
> 
> Was it an interface added to 2.6.24?

Yes.

http://git.kernel.org/?p=linux/kernel/git/davem/net-2.6.git;a=commit;h=31910575a9de61e78065e93846e8e7a4894a18bf


-- 
Pierre Ynard



      _____________________________________________________________________________ 
Ne gardez plus qu'une seule adresse mail ! Copiez vos mails vers Yahoo! Mail 
