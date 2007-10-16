From: Anton Blanchard <anton@samba.org>
Subject: Re: new NAPI interface broken
Date: Tue, 16 Oct 2007 16:01:37 -0500
Message-ID: <20071016210137.GC15989@kryten>
References: <1192519787.7205.3.camel@pasglop> <20071016.004410.85411180.davem@davemloft.net> <1192523336.7205.13.camel@pasglop> <20071016.013146.28785302.davem@davemloft.net> <1192525309.7205.16.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, ossthema@de.ibm.com,
	shemminger@linux-foundation.org, netdev@vger.kernel.org,
	themann@de.ibm.com, raisch@de.ibm.com, arjan@linux.intel.com
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:51460 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965377AbXJPVDr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2007 17:03:47 -0400
Content-Disposition: inline
In-Reply-To: <1192525309.7205.16.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 
Hi,

> As far as I know, the x86 in-kernel thingy doesn't but yeah, the
> userland one seems much more evolved and does things based on the
> "class" of the device.
> 
> Christoph, have any of you tried it on powerpc ?

FYI It works fine on PowerPC and its installed by default on some
distros (eg RHEL5).

Anton
