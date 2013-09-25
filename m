From: Ben Greear <greearb@candelatech.com>
Subject: SCTP will not bind to link-local IPv6 address (3.9.11+ kernel)
Date: Tue, 24 Sep 2013 20:48:30 -0700
Message-ID: <52425D0E.2060706@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:43175 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754770Ab3IYDsc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 23:48:32 -0400
Received: from [50.54.140.2] (50-54-140-2.evrt.wa.frontiernet.net [50.54.140.2])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id r8P3mUoQ010226
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 24 Sep 2013 20:48:31 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I don't have time to track this down now, but I opened a bug so
the issue isn't lost.

https://bugzilla.kernel.org/show_bug.cgi?id=62051

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
