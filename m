From: nik-lists@varna.net
Subject: e1000
Date: Mon, 15 Dec 2008 11:32:47 +0200 (EET)
Message-ID: <0c90d8906ae907db98392f6f52b16ff7.webmail@www.varna.net>
Mime-Version: 1.0
Content-Type: text/plain;charset=windows-1251
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.varna.net ([217.145.80.1]:51374 "EHLO ns.varna.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752164AbYLOJcu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Dec 2008 04:32:50 -0500
Received: from www.varna.net (mail2.Varna.Net [217.145.80.3])
	by ns.varna.net (8.13.6/8.13.6) with ESMTP id mBF9Wlgo030628
	for <netdev@vger.kernel.org>; Mon, 15 Dec 2008 11:32:47 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I am experiencing a big amount of tx_deferred_ok errors with
e1000-8.0.6-NAPI. The error rate varies from 1 to 50 per second, this
interface is loaded no more that 15 kpps and 100 Mbit/s. What is the
typical reason for this type of errors?

I am getting about the same amount of tx_restart_queue errors on the same
interface. My suggestion is that I need to increase the tx ring size. Am I
right?

Thank you very much in advance.

