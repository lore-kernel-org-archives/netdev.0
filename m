From: Ian McDonald <ian.mcdonald@jandi.co.uk>
Subject: Re: [PATCH 1/5] First Patch on TFRC-SP. Copy base files from TFRC
Date: Tue, 15 Sep 2009 06:25:23 +0100
Message-ID: <5640c8aa0909142225q73e477fcga99a48c218d10e0b@mail.gmail.com>
References: <4AA6A25A.5040508@embedded.ufcg.edu.br>
	 <20090912183222.GA5706@gerrit.erg.abdn.ac.uk>
	 <cb00fa210909141738l60d02cd5p287d990326ce6c3c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Gerrit Renker <gerrit@erg.abdn.ac.uk>, dccp@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f206.google.com ([209.85.219.206]:58587 "EHLO
	mail-ew0-f206.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752045AbZIOFZV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2009 01:25:21 -0400
In-Reply-To: <cb00fa210909141738l60d02cd5p287d990326ce6c3c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/9/15 Ivo Calado <ivocalado@embedded.ufcg.edu.br>
>
> Hi Gerrit and all.
> Thank you for your fast reply. My comments follow below
>
> >
> > net/dccp/ccids/lib/tfrc_equation_sp.c
> > -------------------------------------
> > This is a prime candidate for removal. After editing out the whitespace
> > differences, I found that it is 100% identical with tfrc_equation.c.
> >
> > The result of this editing has been uploaded to
> > http://eden-feed.erg.abdn.ac.uk/tfrc_sp_receiver_01.patch
> >
> One future patch will need to modify this file, but now it's really an
> exact copy.
>
>
Basically the rule with a patch set is that all the patches should
make sense together.

It may well be that it makes sense to make a copy, but if you want to
do this then present it with the patch that then modifies it.

Ian
