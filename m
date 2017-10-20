From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 1/8] tools: bpftool: add pointer to file argument
 to print_hex()
Date: Fri, 20 Oct 2017 12:55:23 +0200
Message-ID: <59E9D61B.8010704@iogearbox.net>
References: <20171019224626.31608-1-jakub.kicinski@netronome.com> <20171019224626.31608-2-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: oss-drivers@netronome.com,
        Quentin Monnet <quentin.monnet@netronome.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:49788 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752172AbdJTKz2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 06:55:28 -0400
In-Reply-To: <20171019224626.31608-2-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/20/2017 12:46 AM, Jakub Kicinski wrote:
> From: Quentin Monnet <quentin.monnet@netronome.com>
>
> Make print_hex() able to print to any file instead of standard output
> only, and rename it to fprint_hex(). The function can now be called with
> the info() macro, for example, without splitting the output between
> standard and error outputs.
>
> Signed-off-by: Quentin Monnet <quentin.monnet@netronome.com>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
