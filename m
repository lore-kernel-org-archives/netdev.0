From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: deadlocks if use htb
Date: Fri, 10 Oct 2008 09:44:33 +0400
Message-ID: <48EEEBC1.2090008@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:33753 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756057AbYJJFog (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 01:44:36 -0400
Received: from localhost (localhost [127.0.0.1])
	by mail.bigtelecom.ru (Postfix) with ESMTP id 55C33A6C400
	for <netdev@vger.kernel.org>; Fri, 10 Oct 2008 09:44:34 +0400 (MSD)
Received: from mail.bigtelecom.ru ([127.0.0.1])
	by localhost (mail.bigtelecom.ru [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id eAwq7sruxngs for <netdev@vger.kernel.org>;
	Fri, 10 Oct 2008 09:44:33 +0400 (MSD)
Received: from [87.255.0.131] (slavon.bigtelecom.ru [87.255.0.131])
	by mail.bigtelecom.ru (Postfix) with ESMTP id 361DCA6C35A
	for <netdev@vger.kernel.org>; Fri, 10 Oct 2008 09:44:33 +0400 (MSD)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all!

Please look to if you have time:
http://bugzilla.kernel.org/show_bug.cgi?id=11718

We have deadlocks at few PC one times in week.
I can test any patches to detect and fix problem.
Now i test 2.6.27-rc kernel at one PC.

How information you needed to fast or full debug problem?

Thanks for you doing!

Badalian Vyacheslav aka Slavon
BIG TELECOM CLOSED JSC, Moscow
Network Administrator

