From: Vitaliy Ivanov <vitalivanov@gmail.com>
Subject: Re: linux-next: manual merge of the staging tree with the trivial and
 net trees
Date: Wed, 22 Jun 2011 01:40:48 +0300
Message-ID: <BANLkTimmy0GJMgho4YK62gru6QXGox6Eqg@mail.gmail.com>
References: <20110621151055.0775f17a.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Greg KH <greg@kroah.com>, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jiri Kosina <jkosina@suse.cz>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110621151055.0775f17a.sfr@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen,

On Tue, Jun 21, 2011 at 8:10 AM, Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> Today's linux-next merge of the staging tree got a conflict in
> drivers/staging/brcm80211/brcmfmac/wl_iw.c between commit e44ba033c565
> ("treewide: remove duplicate includes") from the trivial tree, commit
> 219eb47e6f35 ("net/staging: add needed interrupt.h and hardirq.h
> includes") from the net tree and various commits from the staging tree.
>
> I fixed them up (see below) and can carry the fix as necessary.

This one and all the others look good to me.

Vitaliy
