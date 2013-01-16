From: Ben Greear <greearb@candelatech.com>
Subject: 802.1q HW filter spammage in 3.7.2+ kernels.
Date: Tue, 15 Jan 2013 17:36:04 -0800
Message-ID: <50F60404.3090605@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:56357 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756860Ab3APBgF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2013 20:36:05 -0500
Received: from [192.168.100.226] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id r0G1a4dB013143
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 15 Jan 2013 17:36:04 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My kernel logs are full of this (I have 2000 macvlans).

Is this really worth logging?

8021q: adding VLAN 0 to HW filter on device eth3#364
8021q: adding VLAN 0 to HW filter on device eth3#384
8021q: adding VLAN 0 to HW filter on device eth3#434
8021q: adding VLAN 0 to HW filter on device eth3#304
8021q: adding VLAN 0 to HW filter on device eth3#242
8021q: adding VLAN 0 to HW filter on device eth3#312
8021q: adding VLAN 0 to HW filter on device eth3#512
8021q: adding VLAN 0 to HW filter on device eth2#481
8021q: adding VLAN 0 to HW filter on device eth3#262
8021q: adding VLAN 0 to HW filter on device eth3#282

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
