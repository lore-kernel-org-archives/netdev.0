From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 4/4] bpf: also show process name/pid in
 bpf_jit_dump
Date: Thu, 30 Jul 2015 10:18:22 -0700
Message-ID: <55BA5C5E.8040604@plumgrid.com>
References: <cover.1438250937.git.daniel@iogearbox.net>
 <4e1ef7ef805135f77136175858436eeea85ae9e7.1438250937.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: holzheu@linux.vnet.ibm.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:35330 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754479AbbG3RSY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 13:18:24 -0400
Received: by pdrg1 with SMTP id g1so27641480pdr.2
        for <netdev@vger.kernel.org>; Thu, 30 Jul 2015 10:18:23 -0700 (PDT)
In-Reply-To: <4e1ef7ef805135f77136175858436eeea85ae9e7.1438250937.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/30/15 3:42 AM, Daniel Borkmann wrote:
> It can be useful for testing to see the actual process/pid who is loading
> a given filter. I was running some BPF test program and noticed unusual
> filter loads from time to time, triggered by some other application in the
> background. bpf_jit_disasm is still working after this change.
>
> Signed-off-by: Daniel Borkmann<daniel@iogearbox.net>

Acked-by: Alexei Starovoitov <ast@plumgrid.com>
