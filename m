From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Thu, 26 Nov 2015 01:16:14 +0100
Message-ID: <56564F4E.10509@iogearbox.net>
References: <20151126110105.60ec3ddc@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20151126110105.60ec3ddc@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/26/2015 01:01 AM, Stephen Rothwell wrote:
> Hi all,
>
> Today's linux-next merge of the net-next tree got a conflict in:
>
>    kernel/bpf/syscall.c
>
> between commit:
>
>    c9da161c6517 ("bpf: fix clearing on persistent program array maps")
>
> from the net tree and commit:
>
>    f99bf205dab0 ("bpf: add show_fdinfo handler for maps")
>
> from the net-next tree.
>
> I fixed it up (see below) and can carry the fix as necessary (no action
> is required).

Seems fine, thanks!
