From: Jose Alberto Reguero <jareguero@telefonica.net>
Subject: Problem with rtl8192su staging driver
Date: Wed, 28 Jul 2010 17:02:49 +0200
Message-ID: <201007281702.49674.jareguero@telefonica.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from impaqm1.telefonica.net ([213.4.138.1]:57386 "EHLO
	IMPaqm1.telefonica.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752163Ab0G1PLI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jul 2010 11:11:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have a problem with rtl8192su driver. When transmitting the rate is about 10 
Mbytes, but when receiving the rate is about 2 Mbytes. Also I noticed that the 
rx stats don't reflect the correct data. That is with kernel 2.6.34 and with a 
snapshot of rtl8192su driver taken from linux-next.
How I can debug that to find where is the problem?

Jose Alberto


