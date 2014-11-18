From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] PPC: bpf_jit_comp: Unify BPF_MOD | BPF_X and
 BPF_DIV | BPF_X
Date: Tue, 18 Nov 2014 07:37:21 -0800
Message-ID: <CAADnVQ+w9=aezS9uCursLS4Q40S4jcyn=5vNhoc-n5qcyrF0wQ@mail.gmail.com>
References: <1416254861-3879-1-git-send-email-kda@linux-powerpc.org>
	<1416275444.1107.4.camel@concordia>
	<CAOJe8K0_u51QkKmVoVmFuGaDtKfcHP6tSWx_fgJM_erRRoQfUA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Michael Ellerman <mpe@ellerman.id.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Philippe Bergheaud <felix@linux.vnet.ibm.com>,
	linuxppc-dev@ozlabs.org, Daniel Borkmann <dborkman@redhat.com>
To: Denis Kirjanov <kda@linux-powerpc.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f175.google.com ([209.85.216.175]:42623 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754707AbaKRPhY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2014 10:37:24 -0500
Received: by mail-qc0-f175.google.com with SMTP id b13so20118150qcw.34
        for <netdev@vger.kernel.org>; Tue, 18 Nov 2014 07:37:22 -0800 (PST)
In-Reply-To: <CAOJe8K0_u51QkKmVoVmFuGaDtKfcHP6tSWx_fgJM_erRRoQfUA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 17, 2014 at 10:58 PM, Denis Kirjanov <kda@linux-powerpc.org> wrote:
> Hi Michael,
>
> This patch added no new functionality so I haven't put the test
> results (of course I ran the test suite to check the patch).
>
> The output :
> [  650.198958] test_bpf: Summary: 60 PASSED, 0 FAILED

Acked-by: Alexei Starovoitov <ast@plumgrid.com>

btw, please don't top post.
