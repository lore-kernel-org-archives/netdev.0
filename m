From: Ben Greear <greearb@candelatech.com>
Subject: Question on multicast.
Date: Tue, 11 Mar 2014 14:53:03 -0700
Message-ID: <531F85BF.10504@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:51131 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755302AbaCKVxE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 17:53:04 -0400
Received: from [192.168.100.236] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id s2BLr3HM024081
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 11 Mar 2014 14:53:03 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Is it sane to have multiple multicast transmitters using same IGMP group
and destination port in the same routed network?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
