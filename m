From: Andreas Mohr <andi@rhlx01.fht-esslingen.de>
Subject: Re: 2.6.17-mm4
Date: Fri, 30 Jun 2006 13:01:21 +0200
Message-ID: <20060630110121.GA26844@rhlx01.fht-esslingen.de>
References: <20060629013643.4b47e8bd.akpm@osdl.org> <6bffcb0e0606291339s69a16bc5ie108c0b8d4e29ed6@mail.gmail.com> <20060629204330.GC13619@redhat.com> <20060629210950.GA300@elte.hu> <20060629230517.GA18838@elte.hu> <1151662073.31392.4.camel@localhost.localdomain> <1151661242.11434.20.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Ingo Molnar <mingo@elte.hu>,
	Dave Jones <davej@redhat.com>,
	Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhlx01.fht-esslingen.de ([129.143.116.10]:19922 "EHLO
	rhlx01.fht-esslingen.de") by vger.kernel.org with ESMTP
	id S1750803AbWF3LBX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jun 2006 07:01:23 -0400
To: Arjan van de Ven <arjan@infradead.org>
Content-Disposition: inline
In-Reply-To: <1151661242.11434.20.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Fri, Jun 30, 2006 at 11:54:02AM +0200, Arjan van de Ven wrote:
> On Fri, 2006-06-30 at 11:07 +0100, Alan Cox wrote:
> > Not especially. Perhaps the best thing to do here would be to make qdi
> > compiled into the kernel (as opposed to modular) only do so if
> > "probe_qdi=1" or similar is set.
> 
> another quick hack is to check for vesa lb... eg if pci is present, skip
> this thing entirely :)

Eh? You haven't really heard of those quite popular ISA/VLB/PCI 486 combo
boards, now have you? ;)
(IIRC I had one of those things a looooong time ago)

Andreas Mohr
