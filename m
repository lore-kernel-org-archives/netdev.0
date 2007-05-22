From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH 1/2 v4] s2io: add PCI error recovery support
Date: Tue, 22 May 2007 17:47:28 -0500
Message-ID: <20070522224727.GR5921@austin.ibm.com>
References: <20070521185853.GD5921@austin.ibm.com> <20070521144847.439103c4.akpm@linux-foundation.org> <20070521222357.GG5921@austin.ibm.com> <46522281.9040609@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Ramkrishna Vepa <Ramkrishna.Vepa@neterion.com>,
	Sivakumar Subramani <sivakumar.subramani@neterion.com>,
	Sreenivasa Honnur <sreenivasa.honnur@neterion.com>,
	Rastapur Santosh <santosh.rastapur@neterion.com>,
	Wen Xiong <wenxiong@us.ibm.com>,
	linux-pci@atrey.karlin.mff.cuni.cz, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:37948 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755629AbXEVWrc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 May 2007 18:47:32 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4MMlWxq025297
	for <netdev@vger.kernel.org>; Tue, 22 May 2007 18:47:32 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4MMlV14475806
	for <netdev@vger.kernel.org>; Tue, 22 May 2007 18:47:31 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4MMlVvY017120
	for <netdev@vger.kernel.org>; Tue, 22 May 2007 18:47:31 -0400
Content-Disposition: inline
In-Reply-To: <46522281.9040609@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 21, 2007 at 06:51:45PM -0400, Jeff Garzik wrote:
> 
> >The part that confuses me is that I'd gotten a message from Jeff
> >back in March (well before 2.6.21 came out), saying it was in his
> >development tree; yet, the patch its not in 2.6.22-rc; Torvalds
> >hasn't yet pulled from it?
> 
> It only appeared in my tree on May 14.  I tend to drop patches that are 
> repeatedly revised, allowing the dust to settle.

OK, a new patch is coming. I did not want to pester you until after -rc1
came out, but perhaps that was the wrong strategy.

--linas

