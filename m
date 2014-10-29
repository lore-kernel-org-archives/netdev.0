From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] PPC: bpf_jit_comp: add SKF_AD_PKTTYPE instruction
Date: Wed, 29 Oct 2014 10:08:04 -0700
Message-ID: <CAADnVQLmW1var8ebSJJYhmBXCuFbRwX01KXjrnKxyUz1cqFXmA@mail.gmail.com>
References: <1414351406-4122-1-git-send-email-kda@linux-powerpc.org>
	<CAOJe8K0t3G-bHm_24GjrTp9mmKnYZS1_bdGgrwQBLjC_s5is6w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linuxppc-dev@ozlabs.org, Matt Evans <matt@ozlabs.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Denis Kirjanov <kda@linux-powerpc.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f43.google.com ([209.85.192.43]:39422 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933943AbaJ2RIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 13:08:07 -0400
Received: by mail-qg0-f43.google.com with SMTP id f51so2645962qge.30
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2014 10:08:05 -0700 (PDT)
In-Reply-To: <CAOJe8K0t3G-bHm_24GjrTp9mmKnYZS1_bdGgrwQBLjC_s5is6w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 29, 2014 at 2:21 AM, Denis Kirjanov <kda@linux-powerpc.org> wrote:
> Any feedback from PPC folks?

not a ppc guy, but looks reasonable to me.
What lib/test_bpf says? Like performance difference before/after
for LD_PKTTYPE test...
