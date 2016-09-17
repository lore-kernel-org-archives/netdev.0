From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] ip_tunnel: add collect_md mode to
 IPv4/IPv6 tunnels
Date: Sat, 17 Sep 2016 10:13:45 -0400 (EDT)
Message-ID: <20160917.101345.1214078550421374975.davem@davemloft.net>
References: <1473969632-2408261-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, tgraf@suug.ch, netdev@vger.kernel.org,
        kernel-team@fb.com
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60252 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751258AbcIQONs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2016 10:13:48 -0400
In-Reply-To: <1473969632-2408261-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Thu, 15 Sep 2016 13:00:28 -0700

> Similar to geneve, vxlan, gre tunnels implement 'collect metadata' mode
> in ipip, ipip6, ip6ip6 tunnels.

Series applied, thanks.
