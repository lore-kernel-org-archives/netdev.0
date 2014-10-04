From: Artem Bokhan <art@eml.ru>
Subject: distribution of a single stream over all RSS queues
Date: Sat, 04 Oct 2014 13:34:09 +0700
Message-ID: <542F94E1.1090904@eml.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback4.ngs.ru ([195.19.71.24]:42674 "EHLO smtpout.ngs.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750823AbaJDGog (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Oct 2014 02:44:36 -0400
Received: from smtpout.ngs.ru (mc-spool2 [172.16.113.67])
	by mc-spool1.in.ngs.ru (fallback) with ESMTP id 86DEC1834CB
	for <netdev@vger.kernel.org>; Sat,  4 Oct 2014 13:34:24 +0700 (NOVT)
Received: from [192.168.34.3] (unknown [192.168.34.3])
	(Authenticated sender: art@eml.ru)
	by mail.ngs.ru (smtp) with ESMTPA id 84C88201874
	for <netdev@vger.kernel.org>; Sat,  4 Oct 2014 13:34:21 +0700 (NOVT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

Are there any 10gbe cards on the market able to distribute packets from 
a single tcp/udp stream over all RSS queues? Probably there are some 
hooks with registers allowing doing that?

ps. I understand packets reodering problem.
