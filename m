From: "David Shwatrz" <dshwatrz@gmail.com>
Subject: Multicast Routing in IPV4
Date: Fri, 2 May 2008 09:49:07 +0300
Message-ID: <31436f4a0805012349j50d0fdeenf2c51603120f7f1a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.178]:33256 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752347AbYEBGtI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 02:49:08 -0400
Received: by wa-out-1112.google.com with SMTP id j37so118297waf.23
        for <netdev@vger.kernel.org>; Thu, 01 May 2008 23:49:07 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I want to use IPV4 multicast routing with Linux ; I want to use Linux
as the machine which
runs the PIM daemon ; ccording to
net/ipv4/ipmr.c it should work with mrouted; but
mrouted is old and no longer supported.

I had looked for other alternatives;
PIM (Protocol Independent Multicast) based solutions seems to be the most
appropriate; and the linux kernel supports PIMSM V1 and
PIMSM V2 for a long time.

However, PIM based solutions that I found, like netweb.usc.edu/pim are not
available.  I am not sure about other PIM solutions I encountered.

Could anybody recommend  some PIM based daemon which is known to work
with IPv4 multicast routing in Linux ?  A  solution which will accomplish
the basic functionalities of IPV4 multicast routing with 2.6 kernel will do.


Regards,
DS
