From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 2/2] ebpf: misc core cleanup
Date: Fri, 29 May 2015 16:25:08 -0700
Message-ID: <5568F554.2040603@plumgrid.com>
References: <cover.1432912637.git.daniel@iogearbox.net> <331333f9ad9f3317ebf128ee90eb32e64404029e.1432912637.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:32861 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161042AbbE2XZK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 19:25:10 -0400
Received: by pdbqa5 with SMTP id qa5so63859155pdb.0
        for <netdev@vger.kernel.org>; Fri, 29 May 2015 16:25:10 -0700 (PDT)
In-Reply-To: <331333f9ad9f3317ebf128ee90eb32e64404029e.1432912637.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/29/15 2:23 PM, Daniel Borkmann wrote:
> Besides others, move bpf_tail_call_proto to the remaining definitions
> of other protos, improve comments a bit (i.e. remove some obvious ones,
> where the code is already self-documenting, add objectives for others),
> simplify bpf_prog_array_compatible() a bit.
>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

bpf_check_tail_call() cleanup is nice. The rest won't hurt ;)
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
