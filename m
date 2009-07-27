From: "=?windows-1252?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: net-next-2.6 phonet causes build error
Date: Mon, 27 Jul 2009 09:27:55 +0300
Message-ID: <200907270927.55728.remi.denis-courmont@nokia.com>
References: <4A6CA3BF.7010709@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:18352 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753432AbZG0GZg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 02:25:36 -0400
Received: from esebh105.NOE.Nokia.com (esebh105.ntc.nokia.com [172.21.138.211])
	by mgw-mx03.nokia.com (Switch-3.3.3/Switch-3.3.3) with ESMTP id n6R6PO6f008184
	for <netdev@vger.kernel.org>; Mon, 27 Jul 2009 09:25:28 +0300
Received: from leon.remlab.net (esdhcp035142.research.nokia.com [172.21.35.142])
	by mgw-da02.ext.nokia.com (Switch-3.3.3/Switch-3.3.3) with ESMTP id n6R6PKZL004080
	for <netdev@vger.kernel.org>; Mon, 27 Jul 2009 09:25:21 +0300
In-Reply-To: <4A6CA3BF.7010709@hartkopp.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 26 July 2009 21:43:11 ext Oliver Hartkopp wrote:
> i got this build error from the latest net-next-2.6:
>
> net/phonet/pn_dev.c: In function =91phonet_init_net=92:
> net/phonet/pn_dev.c:221: error: implicit declaration of function
> =91proc_net_fops_create=92
> net/phonet/pn_dev.c: In function =91phonet_exit_net=92:
> net/phonet/pn_dev.c:242: error: implicit declaration of function
> =91proc_net_remove=92

Oops. This makes me wonder why I did not get that one here on my test=20
builds???

--=20
R=E9mi Denis-Courmont
Nokia Devices R&D, Maemo Software, Helsinki

