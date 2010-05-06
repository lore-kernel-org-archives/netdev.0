From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 transmit queue time outs
Date: Thu, 6 May 2010 22:10:24 +0200
Message-ID: <20100506201024.GA3541@electric-eye.fr.zoreil.com>
References: <20100506141715.GC4480@ihatethathostname.lab.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Kyle McMartin <kmcmartin@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 97.17.115-78.rev.gaoland.net ([78.115.17.97]:41542 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757097Ab0EFUKi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 16:10:38 -0400
Content-Disposition: inline
In-Reply-To: <20100506141715.GC4480@ihatethathostname.lab.bos.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kyle McMartin <kmcmartin@redhat.com> :
[...]
> Some of our users have been seeing their r8169 cards just up and stop
> transmitting packets pretty quickly after boot with recent kernels.
[...]
> Pid: 0, comm: swapper Not tainted 2.6.31.5-127.fc12.i686.PAE #1

Can they upgrade to 2.6.32.11-99.fc12.i686 and try an out-of-tree build
of the driver at http://userweb.kernel.org/~romieu/r8169/2.6.32.11-99.fc12/ ?

It should be quite close to the current git kernel.

-- 
Ueimor
