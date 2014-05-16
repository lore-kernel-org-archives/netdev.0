From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 2/2] tools: bpf_jit_disasm: increase image buffer
 size
Date: Fri, 16 May 2014 11:35:31 +0200
Message-ID: <5375DBE3.80107@redhat.com>
References: <1400194599-5247-1-git-send-email-ast@plumgrid.com> <1400194599-5247-3-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64004 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751475AbaEPJfg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2014 05:35:36 -0400
In-Reply-To: <1400194599-5247-3-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/16/2014 12:56 AM, Alexei Starovoitov wrote:
> JITed seccomp filters can be quite large if they check a lot of syscalls
> Simply increase buffer size
>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Okay, fine by me.

Acked-by: Daniel Borkmann <dborkman@redhat.com>
