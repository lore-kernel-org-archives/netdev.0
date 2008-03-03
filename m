From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: network namespace ipv6 perfs
Date: Mon, 03 Mar 2008 15:20:16 +0100
Message-ID: <47CC0920.6000005@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Benjamin Thery <benjamin.thery@bull.net>
To: Linux Containers <containers@lists.osdl.org>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:40308 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752219AbYCCOWl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 09:22:41 -0500
Received: from d12nrmr1507.megacenter.de.ibm.com (d12nrmr1507.megacenter.de.ibm.com [9.149.167.1])
	by mtagate6.de.ibm.com (8.13.8/8.13.8) with ESMTP id m23EMdQM131190
	for <netdev@vger.kernel.org>; Mon, 3 Mar 2008 14:22:39 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1507.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m23EMdxA2031654
	for <netdev@vger.kernel.org>; Mon, 3 Mar 2008 15:22:39 +0100
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m23EMcUK005100
	for <netdev@vger.kernel.org>; Mon, 3 Mar 2008 14:22:39 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Some performance tests was made by Benjamin to watch out the impact of=20
the network namespace. The good news is there is no impact when used=20
with or without namespaces. That has been checked using a real network=20
device inside a network namespace.

These results are consistent with the ones previously made for ipv4.

http://lxc.sourceforge.net/network/bench_ipv6_graph.php

Thanks to Benjamin who did all the performance tests :)

Regards
	-- Daniel






















































Sauf indication contraire ci-dessus:
Compagnie IBM France
Si=E8ge Social : Tour Descartes, 2, avenue Gambetta, La D=E9fense 5, 92=
400
Courbevoie
RCS Nanterre 552 118 465
=46orme Sociale : S.A.S.
Capital Social : 542.737.118 ?
SIREN/SIRET : 552 118 465 02430
