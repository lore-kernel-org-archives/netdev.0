From: =?ISO-8859-1?Q?Fran=E7ois_Valenduc?=
	<francois.valenduc@tvcablenet.be>
Subject: Kernel panic at startup with the b44 driver
Date: Mon, 31 May 2010 22:16:25 +0200
Message-ID: <4C041919.3060101@tvcablenet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mirapoint21.brutele.be ([212.68.199.158]:47391 "EHLO
	mirapoint21.brutele.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757301Ab0EaURC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 May 2010 16:17:02 -0400
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
