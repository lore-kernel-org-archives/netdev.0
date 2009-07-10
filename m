From: Jan Engelhardt <jengelh@medozas.de>
Subject: iproute2: adding /128 address to sit interface borks
Date: Fri, 10 Jul 2009 14:05:01 +0200 (CEST)
Message-ID: <alpine.LSU.2.00.0907101402430.21999@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:59018 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752032AbZGJMFD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2009 08:05:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,


it's impossible to do this, and the error message does not say why 
that is so. No word in dmesg either.


# ip a a fc00::49/128 peer fc00::7 dev sit7
RTNETLINK answers: Invalid argument
