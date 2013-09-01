From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
Subject: WLAN setting "Power Management:on" lost after suspend
Date: Sun, 01 Sep 2013 22:01:18 +0200
Message-ID: <52239D0E.3080301@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:52943 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756174Ab3IAUBW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Sep 2013 16:01:22 -0400
Received: from [80.171.177.53] ([80.171.177.53]) by mail.gmx.com (mrgmx101)
 with ESMTPSA (Nemesis) id 0M5HZD-1WDnR80KR5-00zaMn for
 <netdev@vger.kernel.org>; Sun, 01 Sep 2013 22:01:21 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After an s2disk I've to run "iwconfig wlp3s0 power on" again at a
ThinkPad T420 although I did it before suspend.

(kernel 3.11-rc7+, but older kernels shows same behaviour)

Is this intended ?

--=20
MfG/Sincerely
Toralf F=C3=B6rster
pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3
