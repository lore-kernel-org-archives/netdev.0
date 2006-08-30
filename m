From: "franco.daje@virgilio.it" <franco.daje@virgilio.it>
Subject: i not find in the kernel code the code of this command
Date: Wed, 30 Aug 2006 19:46:14 +0100 (GMT+01:00)
Message-ID: <10d6067232b.franco.daje@virgilio.it>
Reply-To: "franco.daje@virgilio.it" <franco.daje@virgilio.it>
Mime-Version: 1.0
Content-Type: text/plain;charset="UTF-8"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from vsmtp3alice.tin.it ([212.216.176.143]:49394 "EHLO vsmtp3.tin.it")
	by vger.kernel.org with ESMTP id S1751355AbWH3TSv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2006 15:18:51 -0400
Received: from pswm18.cp.tin.it (192.168.70.68) by vsmtp3.tin.it (7.2.072.1)
        id 44C91C8801494D9D for netdev@vger.kernel.org; Wed, 30 Aug 2006 20:46:14 +0200
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!,
I'm not able to subscrive at this list. My server mail don't send 
the mail and consider it a spam mail...
For this, please send eventual 
response to this mail address (franco.daje@virgilio.it)
 
The problem 
is this:
I'm searching, in kernel code, the code that implement thi 
command:
 
tc filter add dev eth2 parent ffff: protocol ip prio 1 u32 
match ip src 0.0.0.0/0 police rate $1 burst $2 drop flowid :1
 
I 
thought that this code was police.c but seem that it isn't
i must 
implement a proc file in the code and recompiling the kernel.
 
Thanks
 
Franco
