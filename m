From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: speed regression in udp_lib_lport_inuse()
Date: Fri, 23 Jan 2009 17:05:15 +0100
Message-ID: <4979EABB.4030201@cosmosbay.com>
References: <m3sknbuqf9.wl%vmayatsk@redhat.com>	<4978EE03.9040207@cosmosbay.com>	<m3iqo7dkw4.wl%vmayatsk@redhat.com>	<49790C02.90800@cosmosbay.com>	<m3bpty1hq7.wl%vmayatsk@redhat.com>	<4979ADCA.2080106@cosmosbay.com>	<4979C9B6.3080302@cosmosbay.com> <m3zlhi6pg0.wl%vmayatsk@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Vitaly Mayatskikh <v.mayatskih@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:37471 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756162AbZAWQFV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 11:05:21 -0500
In-Reply-To: <m3zlhi6pg0.wl%vmayatsk@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vitaly Mayatskikh a =E9crit :

> Both randomness and speed are good. There're several never bound port=
s
> in the test, but only few. Thank you for the patch.

I guess "never bound ports" were already in use by other applications o=
n your machine :)



