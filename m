From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] lockdep:  Print more info when MAX_LOCK_DEPTH is exceeded.
Date: Wed, 06 Feb 2013 10:55:23 -0800
Message-ID: <5112A71B.30202@candelatech.com>
References: <1360176762-4321-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:37714 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754094Ab3BFSzY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 13:55:24 -0500
Received: from [192.168.100.226] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id r16ItNAu015803
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2013 10:55:23 -0800
In-Reply-To: <1360176762-4321-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/06/2013 10:52 AM, greearb@candelatech.com wrote:
> From: Ben Greear <greearb@candelatech.com>
>
> This helps debug cases where a lock is acquired over and
> over without being released.
>

Bleh, this should have gone to linux-kernel....fingers too used to
typing netdev...

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
