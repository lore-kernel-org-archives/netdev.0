From: "Grant Likely" <grant.likely@secretlab.ca>
Subject: Re: [PATCH v3 0/4] FEC - fast ethernet controller for mpc52xx
Date: Thu, 18 Oct 2007 08:15:21 -0600
Message-ID: <fa686aa40710180715u23d81adfy83ff65837725fb80@mail.gmail.com>
References: <20071014075511.GC3000@nd47.coderock.org>
	 <4713BA1C.2050604@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Domen Puncer" <domen.puncer@telargo.com>,
	galak@kernel.crashing.org, linuxppc-dev@ozlabs.org, tnt@246tnt.com,
	netdev@vger.kernel.org
To: "Jeff Garzik" <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.176]:4255 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933029AbXJROP1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 10:15:27 -0400
Received: by wa-out-1112.google.com with SMTP id v27so206116wah
        for <netdev@vger.kernel.org>; Thu, 18 Oct 2007 07:15:26 -0700 (PDT)
In-Reply-To: <4713BA1C.2050604@pobox.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/15/07, Jeff Garzik <jgarzik@pobox.com> wrote:
> Domen Puncer wrote:
> > Hello!
> >
> > If there are no objections, I would like to get this merged
> > when bestcomm goes in (any time now?).
> >
> > It's split into four parts:
> > 1 - device tree
> > 2 - small bestcomm change
> > 3 - the actual driver
> > 4 - phy part of the driver
>
> patches #3 and #4 need to be combined together.
>
> Are the arch people OK with patches #1 and #2?

Jeff,

The bestcomm patches and patch 1 & 2 from this series are now in
Linus' tree.  That clears the way for the FEC driver when Domen
reposts it.  (In other words; there is nothing left in arch land
blocking this driver)

Cheers,
g.

-- 
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
grant.likely@secretlab.ca
(403) 399-0195
