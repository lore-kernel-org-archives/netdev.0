From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] bpf: Add map-in-map support
Date: Wed, 22 Mar 2017 15:46:07 -0700 (PDT)
Message-ID: <20170322.154607.22357159467333403.davem@davemloft.net>
References: <20170322170035.923581-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@fb.com, daniel@iogearbox.net,
        Kernel-team@fb.com
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45462 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751355AbdCVWq4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 18:46:56 -0400
In-Reply-To: <20170322170035.923581-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Wed, 22 Mar 2017 10:00:31 -0700

> This patchset adds map-in-map support (map->map).
> One use case is the (vips -> webservers) in the L4 load balancer so
> that different vips can be backed by different set of webservers.
> 
> Please refer to the individual commit log for details.

Series applied, thanks Martin.
