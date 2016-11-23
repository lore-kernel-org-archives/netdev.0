From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 2/2] samples/bpf: fix bpf loader
Date: Wed, 23 Nov 2016 10:57:37 +0100
Message-ID: <58356811.1070407@iogearbox.net>
References: <1479862329-2361912-1-git-send-email-ast@fb.com> <1479862329-2361912-2-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57694 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934143AbcKWJ5m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 04:57:42 -0500
In-Reply-To: <1479862329-2361912-2-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/23/2016 01:52 AM, Alexei Starovoitov wrote:
> llvm can emit relocations into sections other than program code
> (like debug info sections). Ignore them during parsing of elf file
>
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
