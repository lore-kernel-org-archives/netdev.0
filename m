From: "Junfeng Feng" <jfeng@evertz.com>
Subject: IGMP issue with kernel 2.6.31
Date: Wed, 7 May 2014 15:46:28 -0400
Message-ID: <C70A636B101FD44999B82525C3E92AFA03A93B71@otis.burlington.evertz.tv>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.evertz.com ([204.187.63.106]:5926 "EHLO mail.evertz.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750942AbaEGTq3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 15:46:29 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello there,

Right now, I try to support the IGMP functionality on TI Davinci chip
with kernel 2.6.31. I have 
configured the option CONFIG_IP_MULTICAST. But when I try to join or
leave one multicast group, I did not see 
the multicast traffic(monitored with wireshark). For comparison, I have
tried the same test 
program on TI Netra chip with kernel 2.6.37 and there is multicast
message there.

Have anyone encountered the same issue before? Thanks.


Regards,
Junfeng


Regards,
Junfeng
