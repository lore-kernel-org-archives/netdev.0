From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: iputils-s20121106
Date: Tue, 06 Nov 2012 18:07:56 +0900
Message-ID: <5098D36C.1060806@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:52208 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751157Ab2KFJH6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2012 04:07:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

I have just released new snapshot of iputils (iputils-s20121106).

This release basically fixes bugs in ping/ping6 with -f option and
a bug regarding error message in tracepath6.

----
Changes since s20121011:
      ninfod: Attatch configure and renew config.h.in.
      makefile: clean-up
      tracepath6: Print reason on getadrinfo() failure.
      ping,ping6: Fix hang with -f option.
      ping: Make sure to print C if checksum failed with -f option.

----

Release note:
 https://sourceforge.net/p/iputils/code/ci/s20121106/tree/RELNOTES


Download:
 https://sourceforge.net/projects/iputils/files/
 http://www.skbuff.net/iputils/

Regards,

--yoshfuji
