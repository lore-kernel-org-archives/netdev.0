From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 0/8] netfilter updates for net-next
Date: Fri, 16 Jan 2015 21:54:34 +0100
Message-ID: <20150116205434.GA2346@salvia>
References: <1421267689-24894-1-git-send-email-pablo@netfilter.org>
 <20150115.015427.1217684585698382529.davem@davemloft.net>
 <54B97942.7090902@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34153 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754129AbbAPUvj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jan 2015 15:51:39 -0500
Content-Disposition: inline
In-Reply-To: <54B97942.7090902@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 16, 2015 at 09:49:06PM +0100, Oliver Hartkopp wrote:
> I get this problem at 'make module_install' time now:
> 
> DEPMOD  3.19.0-rc4-nn-00578-g919d9db
> depmod: WARNING: /lib/modules/3.19.0-rc4-nn-00578-g919d9db/updates/dkms/xt_DNETMAP.ko needs unknown symbol nf_nat_setup_info
> 
> While 3.19.0-rc4-nn-00504-g4e7a84b was ok.
> 
> Any idea?

I don't see any xt_DNETMAP target in my tree.
