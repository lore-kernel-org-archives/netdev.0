From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [patch 11/11][NETNS][IPV6] rt6_stats - make the stats per network
 namespace
Date: Tue, 04 Mar 2008 21:20:39 +0100
Message-ID: <47CDAF17.1040309@fr.ibm.com>
References: <20080302094243.621444844@mai.toulouse-stg.fr.ibm.com> <20080303.233430.199177100.davem@davemloft.net> <47CD63EE.8090204@bull.net> <20080304.115425.165558612.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: benjamin.thery@bull.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.29.151]:44736 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755488AbYCDUXV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 15:23:21 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.8/8.13.8) with ESMTP id m24KNJSG120102
	for <netdev@vger.kernel.org>; Tue, 4 Mar 2008 20:23:19 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m24KNJpR1913016
	for <netdev@vger.kernel.org>; Tue, 4 Mar 2008 21:23:19 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m24KNJL3022650
	for <netdev@vger.kernel.org>; Tue, 4 Mar 2008 20:23:19 GMT
In-Reply-To: <20080304.115425.165558612.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Benjamin Thery <benjamin.thery@bull.net>
> Date: Tue, 04 Mar 2008 15:59:58 +0100
> 
>> I can't see the patches in net-2.6.26 tree. Have you been forced
>> to revert them because they conflict with Yoshifuji patchset?
> 
> No, I took care of all of the conflicts by hand.

Thank you for taking care of these conflicts :)

