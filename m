From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: net-2.6.25 section warnings
Date: Thu, 13 Dec 2007 11:18:32 +0100
Message-ID: <476106F8.50101@fr.ibm.com>
References: <20071213020722.2790e023.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([195.212.29.137]:27728 "EHLO
	mtagate4.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753655AbXLMKWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 05:22:51 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate4.uk.ibm.com (8.13.8/8.13.8) with ESMTP id lBDAMoOW107896
	for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 10:22:50 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBDAMnQ74366446
	for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 10:22:49 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBDAMX70008158
	for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 10:22:33 GMT
In-Reply-To: <20071213020722.2790e023.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> WARNING: vmlinux.o(.init.text+0x1cfc4): Section mismatch: reference t=
o .exit.text:tcpv6_exit (between 'inet6_init' and 'ac6_proc_init')
> WARNING: vmlinux.o(.init.text+0x1cfc9): Section mismatch: reference t=
o .exit.text:udplitev6_exit (between 'inet6_init' and 'ac6_proc_init')
> WARNING: vmlinux.o(.init.text+0x1cfce): Section mismatch: reference t=
o .exit.text:udpv6_exit (between 'inet6_init' and 'ac6_proc_init')
> WARNING: vmlinux.o(.init.text+0x1cfdd): Section mismatch: reference t=
o .exit.text:addrconf_cleanup (between 'inet6_init' and 'ac6_proc_init'=
)
> WARNING: vmlinux.o(.init.text+0x1d03c): Section mismatch: reference t=
o .exit.text:rawv6_exit (between 'inet6_init' and 'ac6_proc_init')
>=20
> http://userweb.kernel.org/~akpm/config-x.txt (x86_64)
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20

My fault. I will fix that.
Sorry.

   -- Daniel

--=20






















































Sauf indication contraire ci-dessus:
Compagnie IBM France
Si=E8ge Social : Tour Descartes, 2, avenue Gambetta, La D=E9fense 5, 92=
400
Courbevoie
RCS Nanterre 552 118 465
=46orme Sociale : S.A.S.
Capital Social : 542.737.118 ?
SIREN/SIRET : 552 118 465 02430
