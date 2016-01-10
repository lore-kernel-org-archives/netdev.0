From: Lukas Tribus <lukyt@gmx.net>
Subject: netpoll support in SMSC95XX?
Date: Sun, 10 Jan 2016 20:57:53 +0100
Message-ID: <5692B7C1.3090706@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Steve Glendinning <steve.glendinning@shawell.net>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:54112 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757185AbcAJT6F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Jan 2016 14:58:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm wondering if there are any particular obstacles regarding netpoll
support in the SMSC95XX driver (since its USB) and what would be
needed to implement this.

There is a hack here [1], which just uses a dummy function that doesn't
do anything.


Thank you,

Lukas Tribus


[1] http://forum.odroid.com/viewtopic.php?p=41045#p41045
