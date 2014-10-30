From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH] PPC: bpf_jit_comp: add SKF_AD_PKTTYPE instruction
Date: Thu, 30 Oct 2014 15:44:43 +1100
Message-ID: <1414644283.12600.7.camel@concordia>
References: <1414351406-4122-1-git-send-email-kda@linux-powerpc.org>
	 <CAOJe8K0t3G-bHm_24GjrTp9mmKnYZS1_bdGgrwQBLjC_s5is6w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	Matt Evans <matt@ozlabs.org>
To: Denis Kirjanov <kda@linux-powerpc.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:45128 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750744AbaJ3Eop (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Oct 2014 00:44:45 -0400
In-Reply-To: <CAOJe8K0t3G-bHm_24GjrTp9mmKnYZS1_bdGgrwQBLjC_s5is6w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-10-29 at 13:21 +0400, Denis Kirjanov wrote:
> Any feedback from PPC folks?

Hi Denis,

I had a look at this, but I don't know enough about BPF to comment.

Maybe you can explain what a BPF_ANC | SKF_AD_PKTTYPE means and perhaps then we
can guess if the code is correct.

I think testing it is the best option :)

cheers
