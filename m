From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: linux-next: manual merge of the tip tree with the net-next tree
Date: Tue, 07 Apr 2015 09:11:33 -0700
Message-ID: <552401B5.30303@plumgrid.com>
References: <20150407170402.1aeae791@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>,
	Peter Zijlstra <peterz@infradead.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150407170402.1aeae791@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/7/15 12:04 AM, Stephen Rothwell wrote:
> Hi all,
>
> Today's linux-next merge of the tip tree got a conflict in
> samples/bpf/Makefile between commit 91bc4822c3d6 ("tc: bpf: add
> checksum helpers") from the net-next tree and commit b896c4f95ab4
> ("samples/bpf: Add simple non-portable kprobe filter example") (and
> following) from the tip tree.
>
> I fixed it up (see below) and can carry the fix as necessary (no action
> is required).
>

Looks good. Thanks Stephen.
