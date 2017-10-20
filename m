From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 4/8] tools: bpftool: add `bpftool prog help`
 as real command i.r.t exit code
Date: Fri, 20 Oct 2017 12:56:07 +0200
Message-ID: <59E9D647.1020406@iogearbox.net>
References: <20171019224626.31608-1-jakub.kicinski@netronome.com> <20171019224626.31608-5-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: oss-drivers@netronome.com,
        Quentin Monnet <quentin.monnet@netronome.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:49884 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752929AbdJTK4J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 06:56:09 -0400
In-Reply-To: <20171019224626.31608-5-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/20/2017 12:46 AM, Jakub Kicinski wrote:
> From: Quentin Monnet <quentin.monnet@netronome.com>
>
> Make error messages and return codes more consistent. Specifically, make
> `bpftool prog help` a real command, instead of printing usage by default
> for a non-recognized "help" command. Output is the same, but this makes
> bpftool return with a success value instead of an error.
>
> Signed-off-by: Quentin Monnet <quentin.monnet@netronome.com>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
