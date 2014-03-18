From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH -next] netfilter: connlimit: fix UP build
Date: Tue, 18 Mar 2014 10:20:51 +0100
Message-ID: <20140318092051.GA14417@localhost>
References: <53275dbf./J0nBeffRcN62Ddt%fengguang.wu@intel.com>
 <1395091670-28238-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1395091670-28238-1-git-send-email-fw@strlen.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 17, 2014 at 10:27:50PM +0100, Florian Westphal wrote:
> cannot use ARRAY_SIZE() if spinlock_t is empty struct.
> 
> Fixes: 1442e7507dd597 ("netfilter: connlimit: use keyed locks")

Applied, thanks.
