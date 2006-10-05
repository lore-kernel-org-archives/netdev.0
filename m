From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [IPROUTE2][PATCH] Add missing macros which was removed from
 kernel header. (Re: [GIT PATCH] NET: Fixes for net-2.6.19)
Date: Thu, 5 Oct 2006 11:01:12 -0700
Message-ID: <20061005110112.3c07a8b3@freekitty>
References: <20060928155052.63ed5ce8@freekitty>
	<20060928.172827.26929236.davem@davemloft.net>
	<451C7E11.6040506@linux-ipv6.org>
	<200609301627.08278.nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, yoshfuji@linux-ipv6.org,
	tgraf@suug.ch, netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:15569 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751762AbWJESB6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2006 14:01:58 -0400
To: Masahide NAKAMURA <nakam@linux-ipv6.org>
In-Reply-To: <200609301627.08278.nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I applied a combined patch to fix all the headers to iproute2 (for the future
 2.6.19 based release).

-- 
Stephen Hemminger <shemminger@osdl.org>
