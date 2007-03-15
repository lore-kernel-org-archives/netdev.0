From: Samuel Ortiz <samuel@sortiz.org>
Subject: Re: [PATCH 0/6] IrDA: Updates
Date: Fri, 16 Mar 2007 01:19:22 +0200
Message-ID: <20070315231922.GB3821@sortiz.org>
References: <20070314192236.GB3397@sortiz.org> <20070315.030054.78719597.davem@davemloft.net>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp19.orange.fr ([80.12.242.1]:4419 "EHLO smtp19.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992426AbXCOXT0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2007 19:19:26 -0400
Content-Disposition: inline
In-Reply-To: <20070315.030054.78719597.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 15, 2007 at 03:00:54AM -0700, David Miller wrote:
> From: Samuel Ortiz <samuel@sortiz.org>
> Date: Wed, 14 Mar 2007 21:22:36 +0200
> 
> > Some IrDA updates:
> > 
> > - IrNET identation and bug fix. (patches 1 and 2)
> > - IrLAP raw mode initial implementation. (patch 3)
> > - stir4200 and irda-usb fixes. (patches 4 and 5)
> > - hashbin lockdep fixes. (patch 6)
> 
> Indentation and coding-style cleanups are not appropriate for 2.6.21,
> so I need to ask you which of these changes you need to get into
> 2.6.21 and which can go into the non-bug-fix 2.6.22 bound tree?
> 
> When you submit a mish-mash of cleanups and real bug fixes,
> it makes life extremely difficult for me, that's why I totally
> abandoned even looking at this today until right before going
> to sleep.
I understand, sorry about it.
 
> Please properly segregate things in the future and make sure that you
> submit bug fixes against net-2.6 and features against the net-2.6.22
> tree.
I will resend 2 separate patch sets, forget about this one.

Thanks for your patience.

Cheers,
Samuel.

