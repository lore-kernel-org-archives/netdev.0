From: Ben Greear <greearb@candelatech.com>
Subject: e100 firmware in 2.6.29-rc7?
Date: Fri, 13 Mar 2009 13:16:31 -0700
Message-ID: <49BABF1F.9080909@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:49998 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751865AbZCMUQd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 16:16:33 -0400
Received: from [192.168.100.194] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id n2DKGVPV000582
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 13 Mar 2009 13:16:32 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have selected build-firmware-into-kernel
but it seems e100 is still unhappy in 2.6.29-rc7.

e100 0000:02:01.0: firmware: requesting e100/d102e_ucode.bin
e100: eth4: e100_request_firmware: Failed to load firmware "e100/d102e_ucode.bin": -2

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

