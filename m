From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 7 Aug 2017 14:59:49 +1000
Message-ID: <20170807145949.4c4f4dc6@canb.auug.org.au>
References: <20170807120113.5e51eec0@canb.auug.org.au>
        <CADVnQyncPCCp5T+jDU=S4KF-X+Od8sPFJGEdFhWE9k5VABJqFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Yuchung Cheng <ycheng@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CADVnQyncPCCp5T+jDU=S4KF-X+Od8sPFJGEdFhWE9k5VABJqFQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Neal,

On Sun, 6 Aug 2017 22:21:43 -0400 Neal Cardwell <ncardwell@google.com> wrote:
>
> > I fixed it up (see below) and can carry the fix as necessary. This
> > is now fixed as far as linux-next is concerned, but any non trivial
> > conflicts should be mentioned to your upstream maintainer when your tree
> > is submitted for merging.  You may also want to consider cooperating
> > with the maintainer of the conflicting tree to minimise any particularly
> > complex conflicts.  
> 
> Sorry about that. Will try to follow that procedure in the future.

The above is a generic statement I add to all these emails.  It is
aimed more at the maintainers if the trees involved, no the developers
of patches.  I don't think you need to do anything different in these
cases with the "net" and "net-next" tree.  Dave Miller will fix up any
conflicts when he next merges the net tree into the net-next tree.

-- 
Cheers,
Stephen Rothwell
