From: Aldo Maggi <sentiniate@tiscali.it>
Subject: two other cases Re: [Bug 11721] after upgrade to 2.6.27 i cannot
 navigate
Date: Tue, 21 Oct 2008 09:00:02 +0200
Message-ID: <20081021090002.21e64151@topolino>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Netdev <netdev@vger.kernel.org>
To: Ilpo =?UTF-8?B?SsOkcnZpbmVu?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from averell.mail.tiscali.it ([213.205.33.55]:37786 "EHLO
	averell.mail.tiscali.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750874AbYJUHAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 03:00:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

just as matter of information, two other cases similar to mine were
reported in ubuntu bug pages:
https://bugs.launchpad.net/ubuntu/+source/linux/+bug/272896
https://bugs.launchpad.net/ubuntu/+bug/285430
i originated the first one and gave Jarek's first solution:
tcp_sack=0
which worked for the two other users.

maybe they could be contacted in order to perform further tests in a
different environment.

aldo  
