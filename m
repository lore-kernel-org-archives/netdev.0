From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Subject: Re: [PATCHv2 1/4] First Patch on TFRC-SP. Copy base files from TFRC
Date: Tue, 20 Oct 2009 10:51:36 -0300
Message-ID: <cb00fa210910200651r6cc0a7adq971fbc2c21c7fedf@mail.gmail.com>
References: <cb00fa210909141738l60d02cd5p287d990326ce6c3c@mail.gmail.com>
	<4AD4B677.4000308@embedded.ufcg.edu.br> <20091019052153.GB3366@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	Ivo Calado <ivocalado@embedded.ufcg.edu.br>,
	dccp@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:50446 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751190AbZJTNvw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 09:51:52 -0400
In-Reply-To: <20091019052153.GB3366@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 19, 2009 at 02:21, Gerrit Renker <gerrit@erg.abdn.ac.uk> wr=
ote:
> | First Patch on TFRC-SP.
> Please find attached one edit that I made.
>
> I added unwinding the initialisation of tfrc_lib in the case where th=
e
> initialisation of tfrc_sp_lib fails. =A0Unwinding is now done in the =
reverse
> order of the steps done during initialisation.
>

Agree.



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
