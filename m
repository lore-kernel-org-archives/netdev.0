From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2/5] forcedeth: tx collision fix
Date: Wed, 06 Feb 2008 06:43:37 -0500
Message-ID: <47A99D69.40701@pobox.com>
References: <47A77209.1050809@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40792 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759220AbYBFLnk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2008 06:43:40 -0500
In-Reply-To: <47A77209.1050809@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ayaz Abdulla wrote:
> This patch supports a new fix in hardware regarding tx collisions. In 
> the cases where we are in autoneg mode and the link partner is in forced 
> mode, we need to setup the tx deferral register differently in order to 
> reduce collisions on the wire.
> 
> Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>

failed to apply -- conflicts with the existing DEV_xxx flag section

