From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 12/12] tools: bpftool: update documentation for
 --json and --pretty usage
Date: Mon, 23 Oct 2017 22:34:14 +0200
Message-ID: <59EE5246.4040409@iogearbox.net>
References: <20171023162416.32753-1-jakub.kicinski@netronome.com> <20171023162416.32753-13-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        Quentin Monnet <quentin.monnet@netronome.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42080 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751317AbdJWUeP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 16:34:15 -0400
In-Reply-To: <20171023162416.32753-13-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/23/2017 06:24 PM, Jakub Kicinski wrote:
> From: Quentin Monnet <quentin.monnet@netronome.com>
>
> Update the documentation to provide help about JSON output generation,
> and add an example in bpftool-prog manual page.
>
> Also reintroduce an example that was left aside when the tool was moved
> from GitHub to the kernel sources, in order to show how to mount the
> bpffs file system (to pin programs) inside the bpftool-prog manual page.
>
> Signed-off-by: Quentin Monnet <quentin.monnet@netronome.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
