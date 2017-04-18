From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] bpf: remove reference to sock_filter_ext from
 kerneldoc comment
Date: Tue, 18 Apr 2017 11:34:42 +0200
Message-ID: <58F5DDB2.8050308@iogearbox.net>
References: <20170418092700.9157-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@fb.com>
To: Tobias Klauser <tklauser@distanz.ch>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34241 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755614AbdDRJep (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 05:34:45 -0400
In-Reply-To: <20170418092700.9157-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/18/2017 11:27 AM, Tobias Klauser wrote:
> struct sock_filter_ext didn't make it into the tree and is now called
> struct bpf_insn. Reword the kerneldoc comment for bpf_convert_filter()
> accordingly.
>
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Good point, thanks!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
