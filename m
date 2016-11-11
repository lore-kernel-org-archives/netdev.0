From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bpf: fix range arithmetic for bpf map access
Date: Thu, 10 Nov 2016 19:46:07 -0500 (EST)
Message-ID: <20161110.194607.661463406978898589.davem@davemloft.net>
References: <CAG48ez0DyDoySPEkNqYnSEZpTXuuP2xheSuc_EQ+ZzmSwOGy6Q@mail.gmail.com>
        <1478823492-7335-1-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jannh@google.com, daniel@iogearbox.net, ast@kernel.org,
        netdev@vger.kernel.org
To: jbacik@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43026 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935874AbcKKAqZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2016 19:46:25 -0500
In-Reply-To: <1478823492-7335-1-git-send-email-jbacik@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Josef Bacik <jbacik@fb.com>
Date: Thu, 10 Nov 2016 19:18:12 -0500

> ---
> Sorry Jann, I saw your response last night and then promptly forgot about it,
> here's the git-send-email version.

GIT will remove everything after the first "---" line from the commit message,
so you've essentially submitted an empty commit message here.

Put such "---" annotations after the commit message, not at the
beginning.
