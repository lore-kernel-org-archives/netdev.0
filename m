From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2/5] resend forcedeth: tx collision fix
Date: Mon, 11 Feb 2008 11:13:54 -0500
Message-ID: <47B07442.3030408@pobox.com>
References: <47A89D0D.7000700@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:49876 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755484AbYBKQN7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Feb 2008 11:13:59 -0500
In-Reply-To: <47A89D0D.7000700@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ayaz Abdulla wrote:
> This patch supports a new fix in hardware regarding tx collisions. In 
> the cases where we are in autoneg mode and the link partner is in forced 
> mode, we need to setup the tx deferral register differently in order to 
> reduce collisions on the wire.
> 
> Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>

applied


