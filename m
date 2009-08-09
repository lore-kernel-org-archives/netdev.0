From: Tim Schneider <schneid5@cs.uni-bonn.de>
Subject: Reading Route-Metric
Date: Sun, 9 Aug 2009 21:14:30 +0200
Message-ID: <33C861E5-B3AD-4983-8325-23D830A53265@cs.uni-bonn.de>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postfix.iai.uni-bonn.de ([131.220.8.4]:45021 "EHLO
	postfix.iai.uni-bonn.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752779AbZHITOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Aug 2009 15:14:31 -0400
Received: from [10.0.1.10] (dslb-084-063-086-251.pools.arcor-ip.net [84.63.86.251])
	by postfix.iai.uni-bonn.de (Postfix) with ESMTP id 21ECB5C818
	for <netdev@vger.kernel.org>; Sun,  9 Aug 2009 21:14:31 +0200 (MEST)
	(envelope-from schneid5@cs.uni-bonn.de)
	(envelope-to netdev@vger.kernel.org) (1)
	(internal use: ta=1, tu=1, te=1, am=P, au=schneid5)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I've been trying for some time now to find a solution to my problem.  
Since I a new to the kernel I was hoping that someone with more  
experience could help me by giving me a hint on how to solve my problem.
I am writing a Kernel Module and I need to read out the Route-Metric- 
Value of a socket. I want to do this from within TCP, so I can access  
the structs "socket" and "sock" of the socket. As of now, I haven't  
found a way to find out the wanted value with the data I have given. I  
would be grateful, if somebody could give me a hint on how to  
accomplish that task.

Thank you for you Help

Tim Schneider

