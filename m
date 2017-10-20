From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 2/8] tools: bpftool: fix return value when all
 eBPF programs have been shown
Date: Fri, 20 Oct 2017 12:55:39 +0200
Message-ID: <59E9D62B.1040601@iogearbox.net>
References: <20171019224626.31608-1-jakub.kicinski@netronome.com> <20171019224626.31608-3-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: oss-drivers@netronome.com,
        Quentin Monnet <quentin.monnet@netronome.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:49823 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752814AbdJTKzl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 06:55:41 -0400
In-Reply-To: <20171019224626.31608-3-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/20/2017 12:46 AM, Jakub Kicinski wrote:
> From: Quentin Monnet <quentin.monnet@netronome.com>
>
> Change the program to have a more consistent return code. Specifically,
> do not make bpftool return an error code simply because it reaches the
> end of the list of the eBPF programs to show.
>
> Signed-off-by: Quentin Monnet <quentin.monnet@netronome.com>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
