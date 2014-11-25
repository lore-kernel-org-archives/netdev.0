From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: linux-next: manual merge of the net-next tree with the vfs tree
Date: Tue, 25 Nov 2014 09:23:52 -0200
Message-ID: <547466C8.1000203@redhat.com>
References: <20141125134246.2761ada5@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Steven Rostedt (Red Hat)" <rostedt@goodmis.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141125134246.2761ada5@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 25-11-2014 00:42, Stephen Rothwell wrote:
> Hi all,
>
> Today's linux-next merge of the net-next tree got a conflict in
> net/netfilter/nf_log.c between commit e71456ae9871 ("netfilter: Remove
> checks of seq_printf() return values") from the vfs tree and commit
> 0c26ed1c07f1 ("netfilter: nf_log: Introduce nft_log_dereference()
> macro") from the net-next tree.
>
> I fixed it up (see below) and can carry the fix as necessary (no action
> is required).
>

Looks good to me, thanks Stephen.

Marcelo
