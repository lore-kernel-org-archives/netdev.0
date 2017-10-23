From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 01/12] tools: bpftool: copy JSON writer from
 iproute2 repository
Date: Mon, 23 Oct 2017 22:29:57 +0200
Message-ID: <59EE5145.20205@iogearbox.net>
References: <20171023162416.32753-1-jakub.kicinski@netronome.com> <20171023162416.32753-2-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        Quentin Monnet <quentin.monnet@netronome.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41382 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750835AbdJWU37 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 16:29:59 -0400
In-Reply-To: <20171023162416.32753-2-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/23/2017 06:24 PM, Jakub Kicinski wrote:
> From: Quentin Monnet <quentin.monnet@netronome.com>
>
> In prevision of following commits, supposed to add JSON output to the
> tool, two files are copied from the iproute2 repository (taken at commit
> 268a9eee985f): lib/json_writer.c and include/json_writer.h.
>
> Signed-off-by: Quentin Monnet <quentin.monnet@netronome.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
