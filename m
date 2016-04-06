From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net 2/3] samples/bpf: Use llc in PATH, rather than a
 hardcoded value
Date: Wed, 06 Apr 2016 16:02:06 -0400 (EDT)
Message-ID: <20160406.160206.1261557354384285330.davem@davemloft.net>
References: <5ab5eec91d2d0bc7f221d714ef84afac83b2604b.1459789086.git.naveen.n.rao@linux.vnet.ibm.com>
	<5ab5eec91d2d0bc7f221d714ef84afac83b2604b.1459789086.git.naveen.n.rao@linux.vnet.ibm.com>
	<000e23c21f475e7106c74a83eb6226c4cb8d4a14.1459789086.git.naveen.n.rao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, ast@fb.com, daniel@iogearbox.net,
	ananth@in.ibm.com, mpe@ellerman.id.au
To: naveen.n.rao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44674 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752624AbcDFUCS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 16:02:18 -0400
In-Reply-To: <000e23c21f475e7106c74a83eb6226c4cb8d4a14.1459789086.git.naveen.n.rao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Date: Mon,  4 Apr 2016 22:31:33 +0530

> While at it, remove the generation of .s files and fix some typos in the
> related comment.
> 
> Cc: Alexei Starovoitov <ast@fb.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Signed-off-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>

Applied.
