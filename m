From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: linux-next: manual merge of the security tree with the net-next tree
Date: Sun, 3 Aug 2014 23:30:35 -0700
Message-ID: <CAMEtUuxgmUB=MLMjLBpjmb7nQ6nPE2spkmgFVoXDu5Fq6cFYyw@mail.gmail.com>
References: <20140804162633.2d2e8604@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: James Morris <jmorris@namei.org>,
	David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Kees Cook <keescook@chromium.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20140804162633.2d2e8604@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 3, 2014 at 11:26 PM, Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> Hi James,
>
> Today's linux-next merge of the security tree got a conflict in
> kernel/seccomp.c between commit 7ae457c1e5b4 ("net: filter: split
> 'struct sk_filter' into socket and bpf parts") from the net-next tree
> and commits c8bee430dc52 ("seccomp: split filter prep from check and
> apply") and 3ba2530cc06e ("seccomp: allow mode setting across threads")
> from the security tree.
>
> I fixed it up (I hope - see below) and can carry the fix as necessary
> (no action is required).

Looks correct. Thanks.
Will double check during merge window.
