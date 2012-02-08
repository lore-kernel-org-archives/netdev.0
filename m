From: Cong Wang <amwang@redhat.com>
Subject: Re: linux-next: manual merge of the kmap_atomic tree with the  tree
Date: Wed, 08 Feb 2012 17:30:18 +0800
Message-ID: <1328693418.2442.18.camel@cr0>
References: <20120208151057.5ad413a05fbbb393b4a00109@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15159 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751311Ab2BHJal (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Feb 2012 04:30:41 -0500
In-Reply-To: <20120208151057.5ad413a05fbbb393b4a00109@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-02-08 at 15:10 +1100, Stephen Rothwell wrote:
> Hi Cong,
> 
> Today's linux-next merge of the kmap_atomic tree got a conflict in
> drivers/net/ethernet/intel/e1000e/netdev.c between commit 0e15df490eef
> ("e1000e: minor whitespace and indentation cleanup") from the net-next
> tree and commit 2b4ba510a572 ("net: remove the second argument of k
> [un]map_atomic()") from the kmap_atomic tree.
> 
> I fixed it up (see below) and can carry the fix as necessary.

Hi, Stephen,

Looks good, thanks!
