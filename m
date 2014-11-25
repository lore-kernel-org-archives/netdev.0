From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: linux-next: manual merge of the net-next tree with the vfs tree
Date: Tue, 25 Nov 2014 16:56:41 +0100
Message-ID: <20141125155641.GA3817@salvia>
References: <20141125134246.2761ada5@canb.auug.org.au>
 <547466C8.1000203@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Al Viro <viro@ZenIV.linux.org.uk>, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"Steven Rostedt (Red Hat)" <rostedt@goodmis.org>
To: Marcelo Ricardo Leitner <mleitner@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <547466C8.1000203@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 25, 2014 at 09:23:52AM -0200, Marcelo Ricardo Leitner wrote:
> On 25-11-2014 00:42, Stephen Rothwell wrote:
> >Hi all,
> >
> >Today's linux-next merge of the net-next tree got a conflict in
> >net/netfilter/nf_log.c between commit e71456ae9871 ("netfilter: Remove
> >checks of seq_printf() return values") from the vfs tree and commit
> >0c26ed1c07f1 ("netfilter: nf_log: Introduce nft_log_dereference()
> >macro") from the net-next tree.
> >
> >I fixed it up (see below) and can carry the fix as necessary (no action
> >is required).
> >
> 
> Looks good to me, thanks Stephen.

Also to me, thanks Stephen and Marcelo.
