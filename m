From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [GIT 0/3] Second Round of IPVS Updates for v4.12
Date: Fri, 14 Apr 2017 01:01:34 +0200
Message-ID: <20170413230134.GA5724@salvia>
References: <1491843515-1627-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
        netfilter-devel@vger.kernel.org,
        Wensong Zhang <wensong@linux-vs.org>,
        Julian Anastasov <ja@ssi.bg>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:53564 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751670AbdDMXBl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Apr 2017 19:01:41 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id D119FBDF68
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 01:01:36 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 1B95BDA86B
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 01:01:42 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 8D373DA862
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 01:01:39 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <1491843515-1627-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Simon,

On Mon, Apr 10, 2017 at 09:58:32AM -0700, Simon Horman wrote:
> Hi Pablo,
> 
> please consider these clean-ups and enhancements to IPVS for v4.12.
> 
> * Removal unused variable
> * Use kzalloc where appropriate
> * More efficient detection of presence of NAT extension
> 
> 
> The following changes since commit 592d42ac7fd36408979e09bf2f170f2595dab7b8:
> 
>   Merge branch 'qed-IOV-cleanups' (2017-03-21 19:02:38 -0700)
> 
> are available in the git repository at:
> 
>   https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git ipvs2-for-v4.12

This says:

$ git pull
https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git ipvs2-for-v4.12
fatal: Couldn't find remote ref ipvs2-for-v4.12

I don't any tag for this name in:

https://git.kernel.org/pub/scm/linux/kernel/git/horms/ipvs-next.git/refs/tags
