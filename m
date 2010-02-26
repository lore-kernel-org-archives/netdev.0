From: Dan Smith <danms@us.ibm.com>
Subject: Re: [PATCH 2/6] C/R: Basic support for network namespaces and devices (v5)
Date: Fri, 26 Feb 2010 06:56:56 -0800
Message-ID: <87iq9kkptz.fsf@caffeine.danplanet.com>
References: <1267130595-23637-1-git-send-email-danms@us.ibm.com>
	<1267130595-23637-3-git-send-email-danms@us.ibm.com>
	<20100226.040855.158431085.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers@lists.osdl.org, benjamin.thery@bull.net, den@openvz.org,
	ebiederm@xmission.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw0.danplanet.com ([71.245.107.82]:51139 "EHLO
	mail.danplanet.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S964913Ab0BZO5B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 09:57:01 -0500
In-Reply-To: <20100226.040855.158431085.davem@davemloft.net> (David Miller's message of "Fri\, 26 Feb 2010 04\:08\:55 -0800 \(PST\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DM> To be safe you should probably use __be32 and store the IP
DM> addresses in network byte order.

Okay, yeah, good call.

DM> Acked-by: David S. Miller <davem@davemloft.net>

Thanks Dave!

-- 
Dan Smith
IBM Linux Technology Center
email: danms@us.ibm.com
