From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: XFRM does not rate limit messages from the kernel to userspace
Date: Tue, 23 Jan 2007 09:33:36 +0100
Message-ID: <BAY103-DAV15A2D5D7F7F8DB53175163B2AD0@phx.gbl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc1-s8.bay0.hotmail.com ([65.54.246.80]:34460 "EHLO
	bay0-omc1-s8.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932180AbXAWIdv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jan 2007 03:33:51 -0500
To: <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello everybody.
I'm experimenting the problem described in this
bug report http://bugs.xelerance.com/view.php?id=726

The system is running vanilla 2.6.19.2 on Slackware
10.1 (gcc 3.3.5, glibc 2.3.5)

I'm available for any kind of test.
TIA

PS: I see a lot kernel memory allocation:
root@Mimosa:/etc# free
              total       used       free     shared buffers     cached
Mem:        159276     156700       2576          0   0       3108
-/+ buffers/cache:     153592       5684
Swap:       330584      38280     292304


