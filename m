From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [GIT PULL 0/5] IPVS Updates for v4.12
Date: Fri, 17 Mar 2017 12:39:32 +0100
Message-ID: <20170317113932.GA3099@salvia>
References: <1489668195-15240-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
        netfilter-devel@vger.kernel.org,
        Wensong Zhang <wensong@linux-vs.org>,
        Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54940 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751057AbdCQLsn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 17 Mar 2017 07:48:43 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 74F616B193
        for <netdev@vger.kernel.org>; Fri, 17 Mar 2017 12:39:35 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 661EDEBAC4
        for <netdev@vger.kernel.org>; Fri, 17 Mar 2017 12:39:35 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 02E9CEBAC4
        for <netdev@vger.kernel.org>; Fri, 17 Mar 2017 12:39:33 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <1489668195-15240-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 16, 2017 at 01:43:10PM +0100, Simon Horman wrote:
> Hi Pablo,
> 
> please consider these enhancements to the IPVS for v4.12.
> 
> * Update sysctl documentation
> * Remove unnecessary printk in __ip_vs_init
> 
> The following changes since commit 03e5fd0e9bcc1f34b7a542786b34b8f771e7c260:
> 
>   netfilter: nft_set_rbtree: use per-set rwlock to improve the scalability (2017-03-13 19:30:43 +0100)
> 
> are available in the git repository at:
> 
>   https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git tags/ipvs-for-v4.12

Pulled, thanks Simon!
