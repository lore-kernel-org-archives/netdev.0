From: Ben Greear <greearb@candelatech.com>
Subject: Re: IPv6 question on policy based routing.
Date: Fri, 13 Jun 2008 15:39:45 -0700
Message-ID: <4852F731.60703@candelatech.com>
References: <4852EC54.2080608@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([66.165.47.212]:44441 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755334AbYFMWjr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jun 2008 18:39:47 -0400
Received: from [192.168.100.224] (static-71-121-249-218.sttlwa.dsl-w.verizon.net [71.121.249.218])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id m5DMdjnC024005
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 13 Jun 2008 15:39:46 -0700
In-Reply-To: <4852EC54.2080608@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> [root@lanforge-D0-20 lanforge]# ip -6 ru del from all to 2000::2:2 iff 
> rddVR0 lookup local prio 11

Nevermind..as someone kindly showed me, I just can't type.  It should
be iif instead of iff

Sorry about that.

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

