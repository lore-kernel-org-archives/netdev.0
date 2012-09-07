From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v3 2/3] iproute2: add support for tcp_metrics
Date: Fri, 7 Sep 2012 09:09:40 -0700
Message-ID: <20120907090940.30f71a3b@nehalam.linuxnetplumber.net>
References: <1346792597-2427-1-git-send-email-ja@ssi.bg>
	<1346792597-2427-3-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59381 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750746Ab2IGQKI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Sep 2012 12:10:08 -0400
In-Reply-To: <1346792597-2427-3-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Could you resubmit this as two pieces. I can take the libgenl stuff
now (and the l2tp code). The tcp metrics support in iproute2 should be
resent after the kernel support for that makes it to Linus's tree. (ie 3.7 merge window).
