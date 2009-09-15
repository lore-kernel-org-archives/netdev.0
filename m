From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Subject: Re: [PATCH 5/5] Updating documentation accordingly
Date: Mon, 14 Sep 2009 21:41:13 -0300
Message-ID: <cb00fa210909141741r54cd541fi242b110a727fbfcc@mail.gmail.com>
References: <4AA6A26A.6080808@embedded.ufcg.edu.br> <20090913185050.GA7475@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f180.google.com ([209.85.211.180]:39214 "EHLO
	mail-yw0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754720AbZIOAtE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2009 20:49:04 -0400
In-Reply-To: <20090913185050.GA7475@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 13, 2009 at 15:50, Gerrit Renker <gerrit@erg.abdn.ac.uk> wr=
ote:
> | Updating documentation accordingly
>
> +/* As defined at section 8.6.1. of RFC 4342 */
> =A0#define TFRC_LOSS_INTERVALS_OPT_MAX_LENGTH =A0 =A0 28
> +/* Specified on section 8.7. of CCID4 draft */
> =A0#define TFRC_DROP_OPT_MAX_LENGTH =A0 =A0 =A0 =A0 =A0 =A0 =A0 84
> Need to update the references to CCID4 draft with RFC 5622. See also =
4/5.
>
> It would be more helpful to include the documentation for structs wit=
h
> the patches that use these structs.
>

Thanks, I'll fix this.

--=20
Ivo Augusto Andrade Rocha Calado
MSc. Candidate
Embedded Systems and Pervasive Computing Lab - http://embedded.ufcg.edu=
=2Ebr
Systems and Computing Department - http://www.dsc.ufcg.edu.br
Electrical Engineering and Informatics Center - http://www.ceei.ufcg.ed=
u.br
=46ederal University of Campina Grande - http://www.ufcg.edu.br

PGP: 0x03422935
Quidquid latine dictum sit, altum viditur.
