From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 10/12] tools: bpftool: provide JSON output for
 all possible commands
Date: Mon, 23 Oct 2017 22:33:47 +0200
Message-ID: <59EE522B.1070809@iogearbox.net>
References: <20171023162416.32753-1-jakub.kicinski@netronome.com> <20171023162416.32753-11-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        Quentin Monnet <quentin.monnet@netronome.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42006 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751198AbdJWUdt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 16:33:49 -0400
In-Reply-To: <20171023162416.32753-11-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/23/2017 06:24 PM, Jakub Kicinski wrote:
> From: Quentin Monnet <quentin.monnet@netronome.com>
>
> As all commands can now return JSON output (possibly just a "null"
> value), output of `bpftool --json batch file FILE` should also be fully
> JSON compliant.
>
> Signed-off-by: Quentin Monnet <quentin.monnet@netronome.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
