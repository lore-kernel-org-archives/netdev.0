From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH 20/27] drivers/net/wan: fix sparse warnings: make do-while a compound statement
Date: Mon, 22 Dec 2008 23:09:05 +0100
Message-ID: <m3lju7ooam.fsf@maximus.localdomain>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
	<20081222191755.11807.57896.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Hannes Eder <hannes@hanneseder.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:38277 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758590AbYLVWJI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Dec 2008 17:09:08 -0500
In-Reply-To: <20081222191755.11807.57896.stgit@vmbox.hanneseder.net> (Hannes Eder's message of "Mon\, 22 Dec 2008 20\:17\:55 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Eder <hannes@hanneseder.net> writes:

>   drivers/net/wan/wanxl.c:414:3: warning: do-while statement is not a compound statement
>   drivers/net/wan/wanxl.c:441:3: warning: do-while statement is not a compound statement

It's by design.
-- 
Krzysztof Halasa
