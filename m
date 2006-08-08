From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] SNMPv2 tcpOutSegs counter error
Date: Mon, 07 Aug 2006 21:04:29 -0700 (PDT)
Message-ID: <20060807.210429.39330360.davem@davemloft.net>
References: <1154940314.4001.3.camel@LINE>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:28059
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932393AbWHHEEq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 00:04:46 -0400
To: yjwei@nanjing-fnst.com
In-Reply-To: <1154940314.4001.3.camel@LINE>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wei Yongjun <yjwei@nanjing-fnst.com>
Date: Mon, 07 Aug 2006 04:45:13 -0400

> I used tcb->end_seq instead of tcb->seq. And add a new condition 'tcb-
> seq == tcb->end_seq' to make ACK segment to be counted.
 ...
> Signed-off-by: Wei Yongjun <yjwei@nanjing-fnst.com>

Applied, thanks a lot.
