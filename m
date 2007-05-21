From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH 1/2 v4] s2io: add PCI error recovery support
Date: Mon, 21 May 2007 17:23:57 -0500
Message-ID: <20070521222357.GG5921@austin.ibm.com>
References: <20070521185853.GD5921@austin.ibm.com> <20070521144847.439103c4.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Ramkrishna Vepa <Ramkrishna.Vepa@neterion.com>,
	Sivakumar Subramani <sivakumar.subramani@neterion.com>,
	Sreenivasa Honnur <sreenivasa.honnur@neterion.com>,
	Rastapur Santosh <santosh.rastapur@neterion.com>,
	Wen Xiong <wenxiong@us.ibm.com>,
	linux-pci@atrey.karlin.mff.cuni.cz, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:53017 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757015AbXEUWX7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 May 2007 18:23:59 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4LMNxHx013303
	for <netdev@vger.kernel.org>; Mon, 21 May 2007 18:23:59 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4LMNxb8545898
	for <netdev@vger.kernel.org>; Mon, 21 May 2007 18:23:59 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4LMNwMq031275
	for <netdev@vger.kernel.org>; Mon, 21 May 2007 18:23:59 -0400
Content-Disposition: inline
In-Reply-To: <20070521144847.439103c4.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 21, 2007 at 02:48:47PM -0700, Andrew Morton wrote:
> On Mon, 21 May 2007 13:58:53 -0500
> linas@austin.ibm.com (Linas Vepstas) wrote:
> > This patch adds PCI error recovery support to the 
> 
> This is already in Jeff's development tree.  Your new patch neither
> applies nor unapplies, so if you've changed it, Jeff is now sitting
> on an old version.  I assume he'd like an incremental update patch.

Ahh ! 

I assume I have to git-pull
  /pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git
or something like that. Will try that now.

The part that confuses me is that I'd gotten a message from Jeff
back in March (well before 2.6.21 came out), saying it was in his
development tree; yet, the patch its not in 2.6.22-rc; Torvalds
hasn't yet pulled from it?

--linas
