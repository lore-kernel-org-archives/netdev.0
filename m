From: "Grant Likely" <grant.likely@secretlab.ca>
Subject: Re: [PATCH v4.3] FEC - fast ethernet controller for mpc52xx
Date: Mon, 29 Oct 2007 09:37:09 -0600
Message-ID: <fa686aa40710290837k396737b1p80c562f20a4cc407@mail.gmail.com>
References: <4713BA1C.2050604@pobox.com>
	 <20071019112700.GD27403@nd47.coderock.org>
	 <47206209.8080109@pobox.com>
	 <20071025185706.29496.qmail@farnsworth.org>
	 <20071025194114.GH3369@nd47.coderock.org>
	 <20071025202908.GA2102@xyzzy.farnsworth.org>
	 <20071026115909.GI3369@nd47.coderock.org>
	 <20071026141828.GA14900@xyzzy.farnsworth.org>
	 <20071026160749.GA21374@nd47.coderock.org>
	 <4725AF08.6030309@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Domen Puncer" <domen.puncer@telargo.com>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.231]:48368 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752188AbXJ2PhL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2007 11:37:11 -0400
Received: by nz-out-0506.google.com with SMTP id s18so1183544nze
        for <netdev@vger.kernel.org>; Mon, 29 Oct 2007 08:37:11 -0700 (PDT)
In-Reply-To: <4725AF08.6030309@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/29/07, Jeff Garzik <jeff@garzik.org> wrote:
> Domen Puncer wrote:
> >  drivers/net/Kconfig           |   24
> >  drivers/net/Makefile          |    4
> >  drivers/net/fec_mpc52xx.c     | 1112 ++++++++++++++++++++++++++++++++++++++++++
> >  drivers/net/fec_mpc52xx.h     |  313 +++++++++++
> >  drivers/net/fec_mpc52xx_phy.c |  198 +++++++
> >  5 files changed, 1651 insertions(+)
>
> applied to #upstream-fixes
>
> it's not strictly a fix, but I did not want to hold this back until
> 2.6.25 either

Fantastic!  Thanks Jeff.

g.


-- 
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
grant.likely@secretlab.ca
(403) 399-0195
