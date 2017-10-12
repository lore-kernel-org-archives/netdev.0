From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH net-next] selftests: rtnetlink: add a small macsec test
 case
Date: Thu, 12 Oct 2017 12:10:54 +0200
Message-ID: <20171012101054.GA31183@bistromath.localdomain>
References: <20171012091122.28133-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50056 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750918AbdJLKK6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 12 Oct 2017 06:10:58 -0400
Content-Disposition: inline
In-Reply-To: <20171012091122.28133-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2017-10-12, 11:11:22 +0200, Florian Westphal wrote:
> Signed-off-by: Florian Westphal <fw@strlen.de>

Reviewed-by: Sabrina Dubroca <sd@queasysnail.net>

Just a small detail: the "ip macsec" commands actually use genetlink
and not rtnetlink.

-- 
Sabrina
