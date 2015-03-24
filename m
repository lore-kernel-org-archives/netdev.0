From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 23 Mar 2015 22:29:34 -0400 (EDT)
Message-ID: <20150323.222934.1290096929224794650.davem@davemloft.net>
References: <20150323140841.0b807b95@canb.auug.org.au>
	<20150323124723.GA6740@salvia>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	kaber@trash.net
To: pablo@netfilter.org
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20150323124723.GA6740@salvia>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Mon, 23 Mar 2015 13:47:23 +0100

> On Mon, Mar 23, 2015 at 02:08:41PM +1100, Stephen Rothwell wrote:
>> Hi all,
>> 
>> Today's linux-next merge of the net-next tree got a conflict in
>> net/netfilter/nf_tables_core.c between commit 4017a7ee693d ("netfilter:
>> restore rule tracing via nfnetlink_log") from the net tree and commit
>> 01ef16c2dd2e ("netfilter: nf_tables: minor tracing cleanups") from the
>> net-next tree.
>> 
>> I fixed it up (see below) and can carry the fix as necessary (no action
>> is required).
> 
> This looks good, thanks for adressing this conflict Stephen.

Pablo, I just pushed out a merge of net into net-next, please double
check that I handled this conflict correctly.

Thanks!
