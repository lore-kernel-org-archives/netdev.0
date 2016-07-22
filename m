From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/1] netfilter: udp: Remove a bit misleading comment in
 udp_pkt_to_tuple
Date: Fri, 22 Jul 2016 17:11:11 +0200
Message-ID: <20160722151111.GA21492@salvia>
References: <1469093207-5958-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59438 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751082AbcGVPL1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jul 2016 11:11:27 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 446DC1DF88F
	for <netdev@vger.kernel.org>; Fri, 22 Jul 2016 17:11:25 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 27E38100A54
	for <netdev@vger.kernel.org>; Fri, 22 Jul 2016 17:11:25 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 02EDC100A46
	for <netdev@vger.kernel.org>; Fri, 22 Jul 2016 17:11:21 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <1469093207-5958-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 21, 2016 at 05:26:47PM +0800, fgao@ikuai8.com wrote:
> From: Gao Feng <fgao@ikuai8.com>

Please, add description to your patches.

Cc'ing netfilter-devel@vger.kernel.org is sufficient for netfilter
patches unless you really want to attract attention from other netdev
developers, and this is a simple oneliner so it is not the case.

Thanks.
