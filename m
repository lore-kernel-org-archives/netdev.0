From: tino <tinobricchio@gmail.com>
Subject: Indicator of packet/s in tcp
Date: Fri, 03 Feb 2012 16:11:12 +0100
Message-ID: <4F2BF910.6000103@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:46003 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753768Ab2BCPLP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 10:11:15 -0500
Received: by bkcjm19 with SMTP id jm19so3144363bkc.19
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2012 07:11:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi everybody,

It is the first time I write here, so I hope I am not making any mistake.

I am currently trying to understand the tcp part of the kernel, in order 
to develop a project I have in mind.
I need to know if it exists something like byte/s, or packet/s received, 
associated to every sock structure.

I already had a look at struct sock, and tcp_sock, but I didn't find 
anything like that.
Could you help me in any way?

Sorry for my poor english, but if you can't understand what I am saying, 
I will be happy to explain better.

Thanks,

Tino
