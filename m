From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/5] forcedeth: restart tx/rx
Date: Wed, 06 Feb 2008 06:43:01 -0500
Message-ID: <47A99D45.5020302@pobox.com>
References: <47A77207.1080206@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53899 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758998AbYBFLnK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2008 06:43:10 -0500
In-Reply-To: <47A77207.1080206@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ayaz Abdulla wrote:
> This patch fixes the issue where the transmitter and receiver must be 
> restarted when applying new changes to certain registers.
> 
> Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>

applied


