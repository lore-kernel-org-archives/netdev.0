From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/3] tools: add bpftool
Date: Tue, 03 Oct 2017 21:33:28 -0700 (PDT)
Message-ID: <20171003.213328.1196846514896002498.davem@davemloft.net>
References: <20171002231130.12406-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
        alexei.starovoitov@gmail.com, oss-drivers@netronome.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33006 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750796AbdJDEd3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 00:33:29 -0400
In-Reply-To: <20171002231130.12406-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Mon,  2 Oct 2017 16:11:27 -0700

> Hi!
> 
> This set adds bpftool to the tools/ directory.  The first 
> patch renames tools/net to tools/bpf, the second one adds 
> the new code, while the third adds simple documentation.
> 
> v2:
>  - report names, map ids, load time, uid;
>  - add docs/man pages;
>  - general cleanups & fixes.
> 
> Thanks to David Beckett for help with docs and testing.

I think, at the very least, the doc change requests deserve one more
respin.

Thanks.
