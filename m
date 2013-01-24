From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: linux-next: New trees - ipsec and ipsec-next
Date: Thu, 24 Jan 2013 07:13:15 +0100
Message-ID: <20130124061315.GI9147@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Stephen,

could you please add the ipsec and ipsec-next tree to linux-next?

The ipsec tree is intended to cover fixes for the ipsec networking
subsystem and the ipsec-next tree to cover changes for ipsec with
linux-next as target.

The trees are located at:

git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec.git master
git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next.git master

The ipsec tree follows David Miller's net tree, the ipsec-next tree follows
the net-next tree. So they should be merged after net and net-next.

Both trees were pulled recently, so they are currently empty.

Thanks!
