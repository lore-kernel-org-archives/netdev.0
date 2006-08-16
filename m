From: Ritesh Taank <taankr@aston.ac.uk>
Subject: Packet Corruption Support
Date: Wed, 16 Aug 2006 23:50:26 +0100
Message-ID: <44E3A132.7090302@aston.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout03-winn.ispmail.ntl.com ([81.103.221.49]:16620 "EHLO
	mtaout03-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S932309AbWHPWuQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Aug 2006 18:50:16 -0400
Received: from aamtaout04-winn.ispmail.ntl.com ([81.103.221.35])
          by mtaout03-winn.ispmail.ntl.com with ESMTP
          id <20060816225014.RULD1865.mtaout03-winn.ispmail.ntl.com@aamtaout04-winn.ispmail.ntl.com>
          for <netdev@vger.kernel.org>; Wed, 16 Aug 2006 23:50:14 +0100
Received: from [192.168.0.3] (really [86.20.32.95])
          by aamtaout04-winn.ispmail.ntl.com with ESMTP
          id <20060816225014.IFSV15733.aamtaout04-winn.ispmail.ntl.com@[192.168.0.3]>
          for <netdev@vger.kernel.org>; Wed, 16 Aug 2006 23:50:14 +0100
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi there,

I am currently using netem that has been packaged with my linux kernel 
2.6.17 (as part of the Knoppix 5.0.1 Boot CD), and the 'corrupt' 
parameter is not being recognised as a valid argument.

Having read many posts online, it appears that the Packet Corruption 
feature should be supported from kernel versions 2.6.16 onwards.

So I was wondering why my version does not support the corrupt feature?

Are there any kernel versions out there that do support it?

I was wondering if there was a way to patch my existing kernel do enable 
the corruption feature?

Any help/guidance is much appreciate.

Thanks in advance too.

Ritesh

-- 
PhD Researcher
Adaptive Communication Networks Research Group
Electronic Engineering Dept.
Aston University
Birmingham, B4 7ET

t: +44 (0)7732 069 667
e: taankr@aston.ac.uk

