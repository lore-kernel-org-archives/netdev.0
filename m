From: "Gerhard Pircher" <gerhard_pircher@gmx.net>
Subject: Re: 3c59x: shared interrupt problem
Date: Tue, 21 Apr 2009 20:36:14 +0200
Message-ID: <20090421183614.97600@gmx.net>
References: <20090309224253.135220@gmx.net>
 <20090327075937.GA17119@bayes.mathematik.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:50452 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1758047AbZDUSgU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Apr 2009 14:36:20 -0400
In-Reply-To: <20090327075937.GA17119@bayes.mathematik.tu-chemnitz.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


-------- Original-Nachricht --------
> Datum: Fri, 27 Mar 2009 08:59:37 +0100
> Von: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
> An: Gerhard Pircher <gerhard_pircher@gmx.net>
> CC: netdev@vger.kernel.org
> Betreff: Re: 3c59x: shared interrupt problem

> Do you see these messages always when your network hangs and does the
> network recover after such a hang? Could you please send the output o=
f
> 'tc -s qdisc show' after a network hang?
Sorry for the delay! Here's the output of tc after a network hang.

qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 =
1 1 1 1 1 1
 Sent 4633909 bytes 64766 pkt (dropped 0, overlimits 0 requeues 0)=20
 rate 0bit 0pps backlog 0b 0p requeues 0=20

regards,

Gerhard
--=20
Psssst! Schon vom neuen GMX MultiMessenger geh=F6rt? Der kann`s mit all=
en: http://www.gmx.net/de/go/multimessenger01
