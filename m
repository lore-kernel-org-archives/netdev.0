From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: linux-next: manual merge of the tip tree with the net-next tree
Date: Tue, 07 Apr 2015 09:30:45 +0200
Message-ID: <552387A5.5040007@iogearbox.net>
References: <20150407170056.2d89261e@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@plumgrid.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>,
	Peter Zijlstra <peterz@infradead.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60643 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752543AbbDGHbd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 03:31:33 -0400
In-Reply-To: <20150407170056.2d89261e@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/07/2015 09:00 AM, Stephen Rothwell wrote:
...
> Today's linux-next merge of the tip tree got a conflict in
> include/linux/bpf.h between commit 0fc174dea545 ("ebpf: make internal
> bpf API independent of CONFIG_BPF_SYSCALL ifdefs") from the net-next
> tree and commit 4e537f7fbdce ("bpf: Make internal bpf API independent
> of CONFIG_BPF_SYSCALL #ifdefs") from the tip tree.
>
> I fixed it up (they are the same patch and there are other changes in
> the net-next tree, so I just used that version) and can carry the fix
> as necessary (no action is required).

Thanks, Stephen! That is correct.
