From: Fernando Luis =?ISO-8859-1?Q?V=E1zquez?= Cao
	<fernando@oss.ntt.co.jp>
Subject: [IPv6] UDP Encapsulation of IPsec ESP Packets
Date: Mon, 21 May 2007 19:56:39 +0900
Message-ID: <1179744999.12746.88.camel@sebastian.intellilink.co.jp>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from serv1.oss.ntt.co.jp ([222.151.198.98]:46126 "EHLO
	serv1.oss.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755951AbXEULPZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2007 07:15:25 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I noticed that IPv4-over-IPv6 made into 2.6.21 (thank you!) and that
prompted to check the progress with the implementation of rfc3948 (UDP
Encapsulation of IPsec ESP Packets) in Linux. For IPv4 the code is
already there, but that does not seem to be the case for IPv6. I have
checked the usagi kernels and Dave S. Miller's net git tree and could
not find anything.

Is anyone working on this? I would appreciate any information on the
status of this work.

Thank you in advance.

Fernando

