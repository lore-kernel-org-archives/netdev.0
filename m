From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: linux-next: manual merge of the staging tree with the net-next tree
Date: Thu, 27 Mar 2014 12:14:13 -0700
Message-ID: <87ob0rsbcq.fsf@x220.int.ebiederm.org>
References: <20140327160938.c1a4f9a5df6f93e17b55d3cd@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Greg KH <greg@kroah.com>, David Miller <davem@davemloft.net>,
	<netdev@vger.kernel.org>, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Mathieu Maret <mathieu.maret@gmail.com>,
	Jelena Bjelja <jelena.bjelja.ing@gmail.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20140327160938.c1a4f9a5df6f93e17b55d3cd@canb.auug.org.au>
	(Stephen Rothwell's message of "Thu, 27 Mar 2014 16:09:38 +1100")
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Rothwell <sfr@canb.auug.org.au> writes:

> Hi Greg,
>
> Today's linux-next merge of the staging tree got a conflict in
> drivers/staging/wlags49_h2/wl_netdev.c between commit 8d4ade284a41
> ("wlags49_h2: Call dev_kfree/consume_skb_any instead of dev_kfree_skb")
> from the net-next tree and commit fed3ffd8f7ef ("staging: wlags49_h2:
> reindent wl_netdev.c") (and maybe others) from the staging tree.
>
> I fixed it up (see below) and can carry the fix as necessary (no action
> is required).

That looks like the correct resolution.  Thanks,

Eric
