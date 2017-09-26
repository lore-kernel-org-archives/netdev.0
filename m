From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 1/2] tools: rename tools/net directory to tools/bpf
Date: Tue, 26 Sep 2017 23:04:45 +0200
Message-ID: <59CAC0ED.3000208@iogearbox.net>
References: <20170926153522.31500-1-jakub.kicinski@netronome.com> <20170926153522.31500-2-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, davem@davemloft.net,
        hannes@stressinduktion.org, dsahern@gmail.com,
        oss-drivers@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:51833 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1032101AbdIZVEr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 17:04:47 -0400
In-Reply-To: <20170926153522.31500-2-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/26/2017 05:35 PM, Jakub Kicinski wrote:
> We currently only have BPF tools in the tools/net directory.
> We are about to add more BPF tools there, not necessarily
> networking related, rename the directory and related Makefile
> targets to bpf.
>
> Suggested-by: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Reviewed-by: Simon Horman <simon.horman@netronome.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
