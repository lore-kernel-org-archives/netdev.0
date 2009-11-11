From: "Marcus D. Leech" <mleech@ripnet.com>
Subject: SO_TIMESTAMPING: AF_INET6 and AF_PACKET now working
Date: Wed, 11 Nov 2009 01:20:24 -0500
Message-ID: <4AFA57A8.10503@ripnet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.ripnet.com ([66.78.99.10]:3921 "EHLO mx1.ripnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751546AbZKKGUU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Nov 2009 01:20:20 -0500
Received: from localhost.localdomain (unverified [142.46.209.36]) by mx1.ripnet.com
  (Vircom SMTPRS 4.7.840.5) with ESMTP id <B0488821599@mx1.ripnet.com>
  (prot=TLS1-S cifer=RC4-128 hash=MD5-128 exch=RSA-1024 verify=NOT) for <netdev@vger.kernel.org>;
  Wed, 11 Nov 2009 01:20:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have SO_TIMESTAMPING work for AF_INET6 and AF_PACKET now, against a 
2.6.30 kernel.

I'll test it over the next couple of days, and then I guess post a patch 
against the
   2.6.32-rc6 kernel.

Cheers
Marcus

