From: Oren Laadan <orenl@cs.columbia.edu>
Subject: Re: [PATCH 2/6] C/R: Basic support for network namespaces and devices
 (v5)
Date: Fri, 05 Mar 2010 22:55:32 -0500
Message-ID: <4B91D234.2020003@cs.columbia.edu>
References: <1267130595-23637-1-git-send-email-danms@us.ibm.com>	<1267130595-23637-3-git-send-email-danms@us.ibm.com>	<20100226.040855.158431085.davem@davemloft.net> <87iq9kkptz.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, containers@lists.osdl.org,
	den@openvz.org, netdev@vger.kernel.org, ebiederm@xmission.com,
	benjamin.thery@bull.net
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from serrano.cc.columbia.edu ([128.59.29.6]:36966 "EHLO
	serrano.cc.columbia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751590Ab0CFD4M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Mar 2010 22:56:12 -0500
In-Reply-To: <87iq9kkptz.fsf@caffeine.danplanet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Ditto for the existing ipv4 (socket) c/r code ... ?

Dan Smith wrote:
> DM> To be safe you should probably use __be32 and store the IP
> DM> addresses in network byte order.
> 
> Okay, yeah, good call.
> 
> DM> Acked-by: David S. Miller <davem@davemloft.net>
> 
> Thanks Dave!
> 
