From: "news.gmane.org" <francois.valenduc@tvcablenet.be>
Subject: Kernel panic with the b44 driver in 2.6.35-rc1
Date: Mon, 31 May 2010 21:58:43 +0200
Message-ID: <4C0414F3.8030409@tvcablenet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mirapoint3.brutele.be ([212.68.199.148]:57289 "EHLO
	mirapoint3.brutele.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757237Ab0EaUEt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 May 2010 16:04:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello everybody,

I have a kernel panic at startup with the b44 driver with the 2.6.35-rc=
1
kernel. I have submitted a bug report (see
https://bugzilla.kernel.org/show_bug.cgi?id=3D16074) but until know, I
din't get any answer yet. Does anybody knows what's happening. I have
tried several git-bisect run but I didn't find any conclusive result.
The first bad-commit was different each time and if I revert it, the
problem still occurs anyway.

Thanks in advance for your help,
=46ran=E7ois Valenduc
