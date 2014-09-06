From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netfilter: add explicit Kconfig for NETFILTER_XT_NAT
Date: Fri, 05 Sep 2014 17:23:45 -0700 (PDT)
Message-ID: <20140905.172345.529961051265036163.davem@davemloft.net>
References: <1409816841-6446-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	pebolle@tiscali.nl
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1409816841-6446-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Thu,  4 Sep 2014 09:47:21 +0200

> Paul Bolle reports that 'select NETFILTER_XT_NAT' from the IPV4 and IPV6
> NAT tables becomes noop since there is no Kconfig switch for it. Add the
> Kconfig switch to resolve this problem.
> 
> Fixes: 8993cf8 netfilter: move NAT Kconfig switches out of the iptables scope
> Reported-by: Paul Bolle <pebolle@tiscali.nl>
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

Applied, thanks Pablo.
