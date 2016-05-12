From: Christian Kujau <lists@nerdbynature.de>
Subject: Re: networking/ip-sysctl.txt: SRR or SSRR
Date: Wed, 11 May 2016 21:54:11 -0700 (PDT)
Message-ID: <alpine.DEB.2.20.12.1605112154070.3193@trent.utfs.org>
References: <alpine.DEB.2.20.12.1605081823420.3193@trent.utfs.org> <20160510.141356.408283356817506794.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from trent.utfs.org ([94.185.90.103]:52162 "EHLO trent.utfs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751105AbcELEyP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 May 2016 00:54:15 -0400
In-Reply-To: <20160510.141356.408283356817506794.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 May 2016, David Miller wrote:
> Every single variable name and function name dealing with this IP
> option uses "srr", therefore I don't think we should adjust the
> documentation either.
> 
> "srr" covers both the loose source route option and the strict source
> route option.

Now that I know where the 2nd "r" comes from, the "srr" makes sense. So 
yeah, SRR it is. Maybe a hint to the correct RFC would help, but if nobody 
else complained yet, I guess it's not really worth the commit.

Thanks,
Christian.
-- 
BOFH excuse #255:

Standing room only on the bus.
