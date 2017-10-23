From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 03/12] tools: bpftool: introduce --json and --pretty
 options
Date: Mon, 23 Oct 2017 22:30:36 +0200
Message-ID: <59EE516C.4000607@iogearbox.net>
References: <20171023162416.32753-1-jakub.kicinski@netronome.com> <20171023162416.32753-4-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        Quentin Monnet <quentin.monnet@netronome.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41487 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751315AbdJWUaj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 16:30:39 -0400
In-Reply-To: <20171023162416.32753-4-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/23/2017 06:24 PM, Jakub Kicinski wrote:
> From: Quentin Monnet <quentin.monnet@netronome.com>
>
> These two options can be used to ask for a JSON output (--j or -json),
> and to make this JSON human-readable (-p or --pretty).
>
> A json_writer object is created when JSON is required, and will be used
> in follow-up commits to produce JSON output.
>
> Note that --pretty implies --json.
>
> Update for the manual pages and interactive help messages comes in a
> later patch of the series.
>
> Signed-off-by: Quentin Monnet <quentin.monnet@netronome.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
