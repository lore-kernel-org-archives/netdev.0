From: devzero@web.de
Subject: arcnet - weird printk arc%d
Date: Sun, 13 Apr 2008 02:31:16 +0200
Message-ID: <236742536@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate04.web.de ([217.72.192.242]:48118 "EHLO
	fmmailgate04.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753492AbYDMAbT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Apr 2008 20:31:19 -0400
Received: from web.de
	by fmmailgate04.web.de (Postfix) with SMTP id 08B655386D92
	for <netdev@vger.kernel.org>; Sun, 13 Apr 2008 02:31:18 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Apr 13 01:25:50 neo klogd:  arc%d: Given: node 00h, shmem 0h, irq 0
Apr 13 01:25:50 neo klogd:  arc%d: No autoprobe for RIM I; you must spe=
cify the shmem and irq!
Apr 13 01:25:50 neo klogd:  arc%d: No autoprobe for IO mapped cards; yo=
u must specify the base address!

arc%d looks weird - is this intenitonal ?
_______________________________________________________________________
Jetzt neu! Sch=FCtzen Sie Ihren PC mit McAfee und WEB.DE. 30 Tage
kostenlos testen. http://www.pc-sicherheit.web.de/startseite/?mc=3D0222=
20

