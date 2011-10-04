From: sannikov <sannikov@cs.karelia.ru>
Subject: TCP-RENO in Linux
Date: Tue, 04 Oct 2011 19:10:19 +0400
Message-ID: <a894f35e3d8398643b3338248fef0dbf@cs.karelia.ru>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.cs.karelia.ru ([194.85.173.9]:59106 "EHLO
	mail.cs.karelia.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932683Ab1JDPZl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2011 11:25:41 -0400
Received: from localhost (localhost [127.0.0.1])
	by mail.cs.karelia.ru (Postfix) with ESMTP id 30B02A31B8
	for <netdev@vger.kernel.org>; Tue,  4 Oct 2011 19:10:22 +0400 (MSK)
Received: from mail.cs.karelia.ru ([127.0.0.1])
	by localhost (mail.cs.karelia.ru [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id a95CZCIe2SUI for <netdev@vger.kernel.org>;
	Tue,  4 Oct 2011 19:10:19 +0400 (MSK)
Received: from mail.cs.karelia.ru (localhost [127.0.0.1])
	by mail.cs.karelia.ru (Postfix) with ESMTP id C5153A0296
	for <netdev@vger.kernel.org>; Tue,  4 Oct 2011 19:10:19 +0400 (MSK)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

Sorry, maybe this question not for netdev mailing list.

Does anybody works with TCP congestion control (RENO)?
I'm observe strange behavior of RENO: number of
TCP-segments transmitted with some value of 
window is much more than this value.

For example: if window size is 212 it is
transmits 450 segments with such window size.

Can you give me some ideas or search direction.
I will be very thankful to you.

--
With best regards, Alexander Sannikov.
