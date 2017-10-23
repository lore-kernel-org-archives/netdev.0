From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 02/12] tools: bpftool: add option parsing to
 bpftool, --help and --version
Date: Mon, 23 Oct 2017 22:30:11 +0200
Message-ID: <59EE5153.6080107@iogearbox.net>
References: <20171023162416.32753-1-jakub.kicinski@netronome.com> <20171023162416.32753-3-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        Quentin Monnet <quentin.monnet@netronome.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41412 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750835AbdJWUaM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 16:30:12 -0400
In-Reply-To: <20171023162416.32753-3-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/23/2017 06:24 PM, Jakub Kicinski wrote:
> From: Quentin Monnet <quentin.monnet@netronome.com>
>
> Add an option parsing facility to bpftool, in prevision of future
> options for demanding JSON output. Currently, two options are added:
> --help and --version, that act the same as the respective commands
> `help` and `version`.
>
> Signed-off-by: Quentin Monnet <quentin.monnet@netronome.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
