From: Stephen Hemminger <shemminger@vyatta.com>
Subject: iproute2 tools for 2.6.31
Date: Thu, 10 Sep 2009 12:04:16 -0700
Message-ID: <20090910120416.6fd03d1f@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42535 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751845AbZIJTET (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Sep 2009 15:04:19 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.vyatta.com (Postfix) with ESMTP id 526D94F402A
	for <netdev@vger.kernel.org>; Thu, 10 Sep 2009 12:04:23 -0700 (PDT)
Received: from mail.vyatta.com ([127.0.0.1])
	by localhost (mail.vyatta.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id mTWuumsE0FMT for <netdev@vger.kernel.org>;
	Thu, 10 Sep 2009 12:04:18 -0700 (PDT)
Received: from s6510 (c-67-160-158-116.hsd1.or.comcast.net [67.160.158.116])
	by mail.vyatta.com (Postfix) with ESMTP id 85A694F4016
	for <netdev@vger.kernel.org>; Thu, 10 Sep 2009 12:04:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am putting together release for 2.6.31 based tools.
The only open issue is how to deal with the error handling in commands
that do monitoring filtering.  Right now leaning towards the two socket
solution.

So if you have anything else that you have been waiting for,
please drop me a note.
