From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] forcedeth: sideband management fix
Date: Tue, 09 Jan 2007 02:14:47 -0500
Message-ID: <45A340E7.7000406@pobox.com>
References: <3E548BEA.1040101@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60453 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751125AbXAIHPF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jan 2007 02:15:05 -0500
To: Ayaz Abdulla <aabdulla@nvidia.com>
In-Reply-To: <3E548BEA.1040101@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ayaz Abdulla wrote:
> This patch contains a fix that implements proper communication with the 
> sideband management unit. Also, it makes sure that the speed is 
> correctly set for gigabit phys in the case where sideband mgmt unit 
> initialized the phy. Refer to bug #7684 for more details.
> 
> Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>

applied


