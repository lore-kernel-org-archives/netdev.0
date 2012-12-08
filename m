From: Oleg Arkhangelsky <sysoleg@yandex.ru>
Subject: Linux IP forwarding performance benchmarks
Date: Sat, 08 Dec 2012 16:01:33 +0400
Message-ID: <1219381354968093@web3d.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward2.mail.yandex.net ([77.88.46.7]:37319 "EHLO
	forward2.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933031Ab2LHMJ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Dec 2012 07:09:29 -0500
Received: from web3d.yandex.ru (web3d.yandex.ru [77.88.47.178])
	by forward2.mail.yandex.net (Yandex) with ESMTP id EB6EC12A0502
	for <netdev@vger.kernel.org>; Sat,  8 Dec 2012 16:01:33 +0400 (MSK)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Does anyone have some Linux IP forwarding performance
benchmarks on Nehalem Xeon platform versus Sandy
Bridge Xeon E5? Intel DDIO looks pretty tasty and should
give significant  performance boost (at least in theory)
but currently we doesn't have this hardware at hand to
test so asking here.

Thank you!

-- 
wbr, Oleg.

"Anarchy is about taking complete responsibility for yourself."
        Alan Moore.
