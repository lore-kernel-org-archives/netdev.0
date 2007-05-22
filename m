From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/2 v4] s2io: add PCI error recovery support
Date: Tue, 22 May 2007 18:48:26 -0400
Message-ID: <4653733A.3030204@pobox.com>
References: <20070521185853.GD5921@austin.ibm.com> <20070521144847.439103c4.akpm@linux-foundation.org> <20070521222357.GG5921@austin.ibm.com> <46522281.9040609@pobox.com> <20070522224727.GR5921@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Ramkrishna Vepa <Ramkrishna.Vepa@neterion.com>,
	Sivakumar Subramani <sivakumar.subramani@neterion.com>,
	Sreenivasa Honnur <sreenivasa.honnur@neterion.com>,
	Rastapur Santosh <santosh.rastapur@neterion.com>,
	Wen Xiong <wenxiong@us.ibm.com>,
	linux-pci@atrey.karlin.mff.cuni.cz, netdev@vger.kernel.org
To: Linas Vepstas <linas@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56049 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756104AbXEVWsy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 May 2007 18:48:54 -0400
In-Reply-To: <20070522224727.GR5921@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linas Vepstas wrote:
> On Mon, May 21, 2007 at 06:51:45PM -0400, Jeff Garzik wrote:
>>> The part that confuses me is that I'd gotten a message from Jeff
>>> back in March (well before 2.6.21 came out), saying it was in his
>>> development tree; yet, the patch its not in 2.6.22-rc; Torvalds
>>> hasn't yet pulled from it?
>> It only appeared in my tree on May 14.  I tend to drop patches that are 
>> repeatedly revised, allowing the dust to settle.
> 
> OK, a new patch is coming. I did not want to pester you until after -rc1
> came out, but perhaps that was the wrong strategy.

You should be sending patches as soon as they are available, so that 
they do not miss merge window + 1.

	Jeff



