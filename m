From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH] gianfar: Cleanup compile warning caused by 0795af57
Date: Tue, 16 Oct 2007 00:39:52 -0500 (CDT)
Message-ID: <Pine.LNX.4.64.0710160038440.21722@gate.crashing.org>
References: <1192197233-24958-1-git-send-email-leoli@freescale.com>
 <1192197233-24958-2-git-send-email-leoli@freescale.com>
 <1192197233-24958-3-git-send-email-leoli@freescale.com> <4713B46A.70004@pobox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Li Yang <leoli@freescale.com>, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:37281 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751359AbXJPFkH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2007 01:40:07 -0400
In-Reply-To: <4713B46A.70004@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 15 Oct 2007, Jeff Garzik wrote:

> Li Yang wrote:
> > Signed-off-by: Li Yang <leoli@freescale.com>
> > ---
> >  drivers/net/gianfar.c |    1 -
> >  1 files changed, 0 insertions(+), 1 deletions(-)
>
> applied all three gianfar patches
>

Jeff,

You seem to have lost one of the patches:

[PATCH] gianfar: Fix compile regression caused by 09f75cd7

http://marc.info/?l=linux-netdev&m=119219683128258&w=2

- k
