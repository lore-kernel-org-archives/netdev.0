From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: netconsole=y and rtl8139=m
Date: Tue, 20 Nov 2007 08:17:18 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0711200815220.32378@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:36259 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753301AbXKTHRT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 02:17:19 -0500
Received: from localhost (localhost [127.0.0.1])
	by sovereign.computergmbh.de (Postfix) with ESMTP id 1F90D1C052315
	for <netdev@vger.kernel.org>; Tue, 20 Nov 2007 08:17:18 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,



I get this during boot:

[   40.821740] netconsole: eth1 doesn't exist, aborting.

Given that CONFIG_NETCONSOLE=y and CONFIG_8139TOO=m, I can imagine.
Is there a way to get this working without making 8139TOO=y or 
NETCONSOLE=m?



thanks,
Jan
