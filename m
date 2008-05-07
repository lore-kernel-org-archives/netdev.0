From: Ben Greear <greearb@candelatech.com>
Subject: Re: [MACVLAN]: Fix memleak on device removal/crash on module removal
Date: Wed, 07 May 2008 15:03:19 -0700
Message-ID: <48222727.2090606@candelatech.com>
References: <48215DAC.1070704@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([66.165.47.212]:41727 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755796AbYEGWDZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 18:03:25 -0400
In-Reply-To: <48215DAC.1070704@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> 
> ------------------------------------------------------------------------
> 
> commit 2fe876e51d1f053b55d8d50c3733b136b6add016
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Wed May 7 09:43:05 2008 +0200
> 
>     [MACVLAN]: Fix memleak on device removal/crash on module removal

Thanks.  I just tested this on 2.6.23 and it seems to fix the crash.

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

