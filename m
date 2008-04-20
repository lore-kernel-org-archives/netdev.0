From: Carsten Jacobi <carsten@ccac.rwth-aachen.de>
Subject: Help needed, 3com 3c597-TX doesn't trigger interrupts
Date: Sun, 20 Apr 2008 15:38:39 +0200
Message-ID: <480B475F.5020102@ccac.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-in-03.arcor-online.net ([151.189.21.43]:59088 "EHLO
	mail-in-03.arcor-online.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750765AbYDTNiq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Apr 2008 09:38:46 -0400
Received: from mail-in-16-z2.arcor-online.net (mail-in-16-z2.arcor-online.net [151.189.8.33])
	by mail-in-03.arcor-online.net (Postfix) with ESMTP id 7BC632CAAEE
	for <netdev@vger.kernel.org>; Sun, 20 Apr 2008 15:38:45 +0200 (CEST)
Received: from mail-in-07.arcor-online.net (mail-in-07.arcor-online.net [151.189.21.47])
	by mail-in-16-z2.arcor-online.net (Postfix) with ESMTP id 6B4E725411B
	for <netdev@vger.kernel.org>; Sun, 20 Apr 2008 15:38:45 +0200 (CEST)
Received: from [192.168.0.5] (dslb-084-057-206-082.pools.arcor-ip.net [84.57.206.82])
	(Authenticated sender: carlin@arcor.de)
	by mail-in-07.arcor-online.net (Postfix) with ESMTP id 4B8BB292B6C
	for <netdev@vger.kernel.org>; Sun, 20 Apr 2008 15:38:45 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I am trying to get a 3com EISA NIC with the so called "Demon" chipset 
(should be the EISA version of the "Vortex" chip) working here.
Everything seems to be fine now, I can send packets and when I poll the 
adapter status register I can also receive packets. The only shortcoming 
is that I don't get an interrupt each time a packet arrives which makes 
the whole NIC unusable for me, so far.
Contacting 3com-EMEA to get some developer documentation for the chip I 
got the answer that the support program for the product has ended for 
more than five years and hence they don't deliver those documents any more.
My question here: Is still someone out there who knows about trapdoors 
with the 3com cards or still has old documentation about those chipsets? 
Please ...

With kind regards,

Carsten Jacobi
