From: "Leandro Dardini" <l.dardini@comune.prato.it>
Subject: clockdiff and windows machine
Date: Tue, 2 Sep 2008 13:52:15 +0200
Message-ID: <6F861500A5092B4C8CD653DE20A4AA0D96AA16@exchange3.comune.prato.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mbox.comune.prato.it ([193.43.108.62]:34639 "EHLO
	mbox.comune.prato.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751295AbYIBMOk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2008 08:14:40 -0400
Received: from exchange3.comune.prato.local (eggIB-wan.comune.prato.it [193.43.108.2])
	by mbox.comune.prato.it (8.13.1/8.13.1) with ESMTP id m82BqGEo011968
	for <netdev@vger.kernel.org>; Tue, 2 Sep 2008 13:52:16 +0200
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
I'd like to use clockdiff to check time difference from a Linux machine
to a Microsoft Windows one. Unfortunately Microsoft Windows trasmit time
in a non-standard format. I know nothing about how Microsoft send the
time in ICMP packets, but I'd like to know if there is a plan to extend
the capability of clockdiff to understand time from Microsoft machine.

Thank you

Leandro

---------------------
Dott. Leandro Dardini
Sistema Informativo
Comune di Prato
Via Cairoli, 16
59100 Prato PO
Tel: +39 05741835216
Fax: +39 05721835212
