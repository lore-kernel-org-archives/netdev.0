From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 1/2] tools: rename tools/net directory to
 tools/bpf
Date: Tue, 26 Sep 2017 15:19:00 -0700
Message-ID: <20170926221858.y3dl733ydjfnpptq@ast-mbp>
References: <20170926153522.31500-1-jakub.kicinski@netronome.com>
 <20170926153522.31500-2-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, davem@davemloft.net,
        hannes@stressinduktion.org, dsahern@gmail.com,
        oss-drivers@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:43738 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967632AbdIZWTF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 18:19:05 -0400
Received: by mail-pf0-f182.google.com with SMTP id y29so6227536pff.0
        for <netdev@vger.kernel.org>; Tue, 26 Sep 2017 15:19:04 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170926153522.31500-2-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 26, 2017 at 08:35:21AM -0700, Jakub Kicinski wrote:
> We currently only have BPF tools in the tools/net directory.
> We are about to add more BPF tools there, not necessarily
> networking related, rename the directory and related Makefile
> targets to bpf.
> 
> Suggested-by: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Reviewed-by: Simon Horman <simon.horman@netronome.com>

makes sense.
Acked-by: Alexei Starovoitov <ast@kernel.org>
