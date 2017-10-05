From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 0/3] tools: add bpftool
Date: Wed, 04 Oct 2017 21:46:47 -0700 (PDT)
Message-ID: <20171004.214647.434421323387588461.davem@davemloft.net>
References: <20171005031005.15364-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, dsahern@gmail.com, oss-drivers@netronome.com,
        brouer@redhat.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60836 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750761AbdJEEqs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 00:46:48 -0400
In-Reply-To: <20171005031005.15364-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Wed,  4 Oct 2017 20:10:02 -0700

> Hi!
> 
> This set adds bpftool to the tools/ directory.  The first 
> patch renames tools/net to tools/bpf, the second one adds 
> the new code, while the third adds simple documentation.
> 
> v4:
>  - rename docs *.txt -> *.rst (Jesper).
> v3:
>  - address Alexei's comments about output and docs.
> v2:
>  - report names, map ids, load time, uid;
>  - add docs/man pages;
>  - general cleanups & fixes.

Series applied, although there was some trailing whitespace I had to fix
up in patch #3.
