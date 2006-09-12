From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Pull request for 'r8169-20060912-00' branch
Date: Tue, 12 Sep 2006 22:38:54 +0200
Message-ID: <20060912203854.GA1793@electric-eye.fr.zoreil.com>
References: <20060912193531.GB4482@electric-eye.fr.zoreil.com> <20060912201722.GA29802@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:44951 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1030425AbWILUkw
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Sep 2006 16:40:52 -0400
To: Lennert Buytenhek <buytenh@wantstofly.org>
Content-Disposition: inline
In-Reply-To: <20060912201722.GA29802@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lennert Buytenhek <buytenh@wantstofly.org> :
[...]
> Not that it matters much either way, but my impression was that this
> was an 8110SB bug rather than an iop3xx bug, as the same iop3xx ARM
> board sports a VIA PCI USB controller and a Silicon Image PCI SATA
> controller, which both work without any problems.

I believe it is a 8110sb bug too and I plead guilty on broken wording.
Notwithstanding the fact that the 8110sb has been in town for some time,
the issue has been reported quite late. Thus I would not be surprized
that the bug can not be reproduced, say, on x86.

Hopefully the bug won't be noticed anywhere now. :o)

-- 
Ueimor
