From: Arnd Hannemann <arnd@arndnet.de>
Subject: Changing the default for net.ipv6.conf.*.use_tempaddr
Date: Thu, 12 May 2011 09:57:41 +0200
Message-ID: <4DCB92F5.3050008@arndnet.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from slowhand.arndnet.de ([88.198.19.76]:43845 "EHLO mail.unitix.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751449Ab1ELH5o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 May 2011 03:57:44 -0400
Received: from [172.26.14.109] (exit.credativ.com [87.139.82.80])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail.unitix.de (Postfix) with ESMTP id 6F01113EA5
	for <netdev@vger.kernel.org>; Thu, 12 May 2011 09:57:42 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

while reading all the pro and cons mentioned in a recent discussion[1]
on debian-devel I wonder if there was a particular reason why
Privacy Extensions are disabled by default in linux?

Maybe it is time to reconsider the default?

Best regards
Arnd

[1] http://lists.debian.org/debian-devel/2011/05/msg00462.html
