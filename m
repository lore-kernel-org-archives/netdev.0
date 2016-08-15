From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 15 Aug 2016 09:51:59 +0200
Message-ID: <57B1749F.8040100@iogearbox.net>
References: <20160815103503.2ff7aa58@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sargun Dhillon <sargun@sargun.me>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>,
	Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20160815103503.2ff7aa58@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/15/2016 02:35 AM, Stephen Rothwell wrote:
> Hi all,
>
> Today's linux-next merge of the net-next tree got a conflict in:
>
>    kernel/bpf/verifier.c
>
> between commit:
>
>    747ea55e4f78 ("bpf: fix bpf_skb_in_cgroup helper naming")
>
> from the net tree and commit:
>
>    60d20f9195b2 ("bpf: Add bpf_current_task_under_cgroup helper")
>
> from the net-next tree.
>
> I fixed it up (see below) and can carry the fix as necessary.

Looks good to me, thanks!
