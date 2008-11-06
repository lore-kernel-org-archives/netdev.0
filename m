From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH 2/6] smsc911x: add dynamic bus configuration
Date: Thu, 06 Nov 2008 13:10:10 +0000
Message-ID: <1225977010.16885.14.camel@pc1117.cambridge.arm.com>
References: <1225881342-3485-1-git-send-email-steve.glendinning@smsc.com>
	 <1225881342-3485-2-git-send-email-steve.glendinning@smsc.com>
	 <1225881342-3485-3-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dustin@sensoria.com, bgat@billgatliff.com,
	Ian Saturley <ian.saturley@smsc.com>, g.liakhovetski@gmx.de,
	Peter Korsgaard <jacmet@sunsite.dk>
To: Steve Glendinning <steve.glendinning@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cam-admin0.cambridge.arm.com ([193.131.176.58]:55469 "EHLO
	cam-admin0.cambridge.arm.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753432AbYKFNK3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2008 08:10:29 -0500
In-Reply-To: <1225881342-3485-3-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-11-05 at 10:35 +0000, Steve Glendinning wrote:
> Convert the driver to select 16-bit or 32-bit bus access at runtime,
> at a small performance cost.
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

I tested it on the RealView platforms and works OK (can't tell about the
other platforms).

-- 
Catalin

