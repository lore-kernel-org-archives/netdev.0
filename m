From: Nigel Kukard <nkukard@lbsd.net>
Subject: iproute2/tc and major/minor limits
Date: Mon, 14 Oct 2013 21:45:03 +0000
Message-ID: <sig.1999180836.525C65DF.1020700@lbsd.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from uk.eu.mailhost.iitsp.com ([217.147.85.13]:47716 "EHLO
	uk.eu.mailhost.iitsp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757547Ab3JNVxH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Oct 2013 17:53:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi guys,

I'm just curious if there is any specific reason why 32-bit integers are 
used with tc imposing the limit of 0xfff maximum major and minor numbers 
for classes? (more specifically architectural or algorithmic reasons)

-N
