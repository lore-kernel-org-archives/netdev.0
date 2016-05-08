From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [GIT PULL nf-next 0/1] Second Round of IPVS Updates for v4.7
Date: Mon, 9 May 2016 00:19:26 +0200
Message-ID: <20160508221926.GA10292@salvia>
References: <1462519959-22382-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Wensong Zhang <wensong@linux-vs.org>,
	Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58714 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750878AbcEHWTb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 May 2016 18:19:31 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 10EA11B5342
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 00:19:30 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id EBC7533AB
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 00:19:29 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 5C9D1D1D85
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 00:19:27 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <1462519959-22382-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 06, 2016 at 04:32:38PM +0900, Simon Horman wrote:
> Hi Pablo,
> 
> please consider these enhancements to the IPVS. They allow its
> DoS mitigation strategy effective in conjunction with the SIP persistence
> engine.
> 
> The following changes since commit cb39ad8b8ef224c544074962780bf763077d6141:
> 
>   netfilter: nf_tables: allow set names up to 32 bytes (2016-05-05 16:39:51 +0200)
> 
> are available in the git repository at:
> 
>   https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs2-for-v4.7

Pulled, thanks Simon.
