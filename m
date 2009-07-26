From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: net-next-2.6 phonet causes build error
Date: Sun, 26 Jul 2009 20:43:11 +0200
Message-ID: <4A6CA3BF.7010709@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: =?windows-1252?Q?R=E9mi_Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:56003 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753357AbZGZSnN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jul 2009 14:43:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Remi,

i got this build error from the latest net-next-2.6:

net/phonet/pn_dev.c: In function =91phonet_init_net=92:
net/phonet/pn_dev.c:221: error: implicit declaration of function
=91proc_net_fops_create=92
net/phonet/pn_dev.c: In function =91phonet_exit_net=92:
net/phonet/pn_dev.c:242: error: implicit declaration of function =91pro=
c_net_remove=92

Regards,
Oliver
