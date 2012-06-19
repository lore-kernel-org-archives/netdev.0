From: Stefan Priebe <s.priebe@profihost.ag>
Subject: 10GBE performance drop with net.ipv4.tcp_timestamps=0
Date: Tue, 19 Jun 2012 23:08:03 +0200
Message-ID: <4FE0EA33.1000309@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.profihost.ag ([85.158.179.208]:37187 "EHLO
	mail.profihost.ag" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752873Ab2FSVIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 17:08:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello List,

i'm testing 10GBE speed with tweo servers. One with 3.5-rc3 nd thoe 
other one whith RHEL 6 (2.6.32 kernel).

I noticed that setting
net.ipv4.tcp_timestamps=0

descreased the performance from 9,7 Full Duplex to 3-4Gb/s.

Is this bahviour fine? What should / could i tet?

Greets
Stefan
