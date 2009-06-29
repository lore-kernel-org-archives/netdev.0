From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Unix socket sendpage
Date: Mon, 29 Jun 2009 15:13:30 +0300
Message-ID: <200906291513.30426.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:17006 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753057AbZF2MLf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2009 08:11:35 -0400
Received: from esebh106.NOE.Nokia.com (esebh106.ntc.nokia.com [172.21.138.213])
	by mgw-mx06.nokia.com (Switch-3.3.3/Switch-3.3.3) with ESMTP id n5TCBAUs030737
	for <netdev@vger.kernel.org>; Mon, 29 Jun 2009 15:11:29 +0300
Received: from leon.remlab.net (esdhcp03532.research.nokia.com [172.21.35.32])
	by mgw-sa01.ext.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id n5TCBWko022696
	for <netdev@vger.kernel.org>; Mon, 29 Jun 2009 15:11:33 +0300
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

Am I unaware of some fundamental reasons why AF_UNIX sockets do not sup=
port=20
sendpage(splice)? or is it just that nobody bothered to write the code?

--=20
R=E9mi Denis-Courmont
Nokia Devices R&D, Maemo Software, Helsinki

