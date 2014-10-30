From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [GIT PULL nf-next] IPVS Updates for v3.19
Date: Thu, 30 Oct 2014 17:30:39 +0100
Message-ID: <20141030163039.GA2270@salvia>
References: <1414457960-20864-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Wensong Zhang <wensong@linux-vs.org>,
	Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:33941 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933047AbaJ3Q3A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Oct 2014 12:29:00 -0400
Content-Disposition: inline
In-Reply-To: <1414457960-20864-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 28, 2014 at 09:59:19AM +0900, Simon Horman wrote:
> Hi Pablo,
> 
> please consider these IPVS updates for v3.19.
> 
> The single patch in this series fixes some minor fallout from adding
> support IPv6 real servers in IPv4 virtual-services and vice versa.
> 
> It should not have any run-time affect other than perhaps saving a few cycles.
> 
> 
> The following changes since commit 61ed53deb1c6a4386d8710dbbfcee8779c381931:
> 
>   Merge tag 'ntb-3.18' of git://github.com/jonmason/ntb (2014-10-19 12:58:22 -0700)
> 
> are available in the git repository at:
> 
>   https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs-for-v3.19

Pulled, thanks Simon.
