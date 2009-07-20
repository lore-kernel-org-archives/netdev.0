From: "=?utf-8?q?R=C3=A9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH] Phonet: sockets list through proc_fs
Date: Mon, 20 Jul 2009 12:47:22 +0300
Message-ID: <200907201247.23020.remi.denis-courmont@nokia.com>
References: <1248078849-7343-1-git-send-email-remi.denis-courmont@nokia.com> <200907201228.47125.remi.denis-courmont@nokia.com> <1248082487.4549.102.camel@violet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:32184 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751267AbZGTJpj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2009 05:45:39 -0400
Received: from vaebh106.NOE.Nokia.com (vaebh106.europe.nokia.com [10.160.244.32])
	by mgw-mx09.nokia.com (Switch-3.3.3/Switch-3.3.3) with ESMTP id n6K9jJgR011697
	for <netdev@vger.kernel.org>; Mon, 20 Jul 2009 04:45:31 -0500
Received: from leon.remlab.net (esdhcp03592.research.nokia.com [172.21.35.92])
	by mgw-sa01.ext.nokia.com (Switch-3.3.3/Switch-3.3.3) with ESMTP id n6K9ixP0017907
	for <netdev@vger.kernel.org>; Mon, 20 Jul 2009 12:44:59 +0300
In-Reply-To: <1248082487.4549.102.camel@violet>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 20 July 2009 12:34:47 ext Marcel Holtmann wrote:
> Hi Remi,
>
> > > > From: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
> > >
> > > isn't there are proper explaining commit message missing here?
> >
> > AFAIK, a one-liners stick to the Subject line.
> >
> > (I use explicit From: due to my broken Microsoft-provided MTA).
>
> the From: is not the problem here. However it would be nice to have a
> description of the change. Especially details like this is for debugg=
ing
> or this is a public API or etc.

It's just like most network protocols exposing their sockets list in=20
/proc/net. Debugging/monitoring indeed.

--=20
R=C3=A9mi Denis-Courmont
Nokia Devices R&D, Maemo Software, Helsinki

