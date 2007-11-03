From: "auther_bin" <auther_bin@tom.com>
Subject: urgent!  linux 2.6.16 network bridge crash
Date: Sat, 3 Nov 2007 19:11:34 +0800
Message-ID: <200711031904486275450@tom.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="gb2312"
Content-Transfer-Encoding: 7bit
To: "netdev" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpr3.tom.com ([202.108.255.198]:63405 "HELO tom.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753092AbXKCLNe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Nov 2007 07:13:34 -0400
Received: from authernote (unknown [172.24.140.61])
	by bjapp11 (Coremail) with SMTP id O0AIAONXLEc7AIw9.1
	for <netdev@vger.kernel.org>; Sat, 03 Nov 2007 19:13:39 +0800 (CST)
Received: from authernote([218.249.84.34])
	by bjapp21.tom.com(KBAS Gateway 2.1 2.126i4g2) with ESMTP id local17883.1194088406 for <netdev@vger.kernel.org>;
	Sat Nov  3 19:13:27 2007 +0800
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello friends, I have config my linux box works as a network bridge. and
up/down switch is both cisco 35xx works with vlan. but when i connect it
into the network the box crashed right now. Puzzled!

btw, in the down(intranet) switch we connect 8 wireless AP.

tcpdump gives many many broadcast package like:

time serial M SRC_MAC > 1:0:0:0:0:0 sap aa ui/C

what's it?
flood? or the AP package or the cisco vlan? but whatever it is, the box
should not be crashed by it, right?

if the box do not use bridge, it will not crash at all.


