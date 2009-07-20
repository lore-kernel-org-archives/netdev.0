From: "=?utf-8?q?R=C3=A9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH] Phonet: sockets list through proc_fs
Date: Mon, 20 Jul 2009 13:32:04 +0300
Message-ID: <200907201332.05329.remi.denis-courmont@nokia.com>
References: <1248078849-7343-1-git-send-email-remi.denis-courmont@nokia.com> <200907201247.23020.remi.denis-courmont@nokia.com> <1248085261.4549.103.camel@violet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:36474 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751267AbZGTKaD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2009 06:30:03 -0400
Received: from vaebh105.NOE.Nokia.com (vaebh105.europe.nokia.com [10.160.244.31])
	by mgw-mx09.nokia.com (Switch-3.3.3/Switch-3.3.3) with ESMTP id n6KATnRs016329
	for <netdev@vger.kernel.org>; Mon, 20 Jul 2009 05:29:55 -0500
Received: from leon.remlab.net (esdhcp03592.research.nokia.com [172.21.35.92])
	by mgw-sa02.ext.nokia.com (Switch-3.3.3/Switch-3.3.3) with ESMTP id n6KAThfc003214
	for <netdev@vger.kernel.org>; Mon, 20 Jul 2009 13:29:43 +0300
In-Reply-To: <1248085261.4549.103.camel@violet>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 20 July 2009 13:21:01 ext Marcel Holtmann wrote:
> > It's just like most network protocols exposing their sockets list i=
n
> > /proc/net. Debugging/monitoring indeed.
>
> I think that for new protocols, we should not do this anymore and jus=
t
> use debugfs. Since that is exactly its job.

Requiring debugfs for something like 'netstat' sounds restrictive to me=
=2E..

--=20
R=C3=A9mi Denis-Courmont
Nokia Devices R&D, Maemo Software, Helsinki

