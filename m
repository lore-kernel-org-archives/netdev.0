From: MOKUNO Masakazu <mokuno@sm.sony.co.jp>
Subject: [PATCH 0/2] RFC: PS3 network driver
Date: Fri, 01 Jun 2007 15:14:58 +0900
Message-ID: <20070601151429.2C46.MOKUNO@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Geoff Levand <geoffrey.levand@am.sony.com>,
	Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from MGW2.Sony.CO.JP ([137.153.0.14]:57409 "EHLO mgw2.sony.co.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755301AbXFAGPH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jun 2007 02:15:07 -0400
Received: from mail5.sony.co.jp (localhost [127.0.0.1])
	by mail5.sony.co.jp (R8/Sony) with ESMTP id l516F4Kl000950
	for <netdev@vger.kernel.org>; Fri, 1 Jun 2007 15:15:04 +0900 (JST)
Received: from smail1.sm.sony.co.jp (smail1.sm.sony.co.jp [43.11.253.1])
	by mail5.sony.co.jp (R8/Sony) with ESMTP id l516F30x000923
	for <netdev@vger.kernel.org>; Fri, 1 Jun 2007 15:15:04 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

This is the first submission of the PS3 network driver
 [1] ps3: gigabit ethernet driver for PS3
 [2] ps3: add wireless LAN support for PS3

They are submitted for review since some of the underlying
infrastructure code hasn't been submitted yet.
For reference, you can take a look at Geoff's git tree
(git://git.kernel.org/pub/scm/linux/kernel/git/geoff/ps3-linux.git).

I appreciate your comments.

--
Masakazu MOKUNO

