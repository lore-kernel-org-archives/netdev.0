From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 04/12] tools: bpftool: add JSON output for `bpftool
 prog show *` command
Date: Mon, 23 Oct 2017 22:30:59 +0200
Message-ID: <59EE5183.2030903@iogearbox.net>
References: <20171023162416.32753-1-jakub.kicinski@netronome.com> <20171023162416.32753-5-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        Quentin Monnet <quentin.monnet@netronome.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41538 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751250AbdJWUbB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 16:31:01 -0400
In-Reply-To: <20171023162416.32753-5-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/23/2017 06:24 PM, Jakub Kicinski wrote:
> From: Quentin Monnet <quentin.monnet@netronome.com>
>
> Reuse the json_writer API introduced in an earlier commit to make
> bpftool able to generate JSON output on `bpftool prog show *` commands.
>
> For readability, the code from show_prog() has been split into two
> functions, one for plain output, one for JSON.
>
> Outputs from sample programs have been successfully tested against a
> JSON validator.
>
> Signed-off-by: Quentin Monnet <quentin.monnet@netronome.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
