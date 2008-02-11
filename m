From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 4/5] resend forcedeth: tx pause watermarks
Date: Mon, 11 Feb 2008 11:14:00 -0500
Message-ID: <47B07448.50208@pobox.com>
References: <47A89D19.9060003@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:49883 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755847AbYBKQOE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Feb 2008 11:14:04 -0500
In-Reply-To: <47A89D19.9060003@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ayaz Abdulla wrote:
> New chipsets introduced variant Rx FIFO sizes that need to be taken into 
> account when setting up the tx pause watermarks. This patch introduces 
> the new device feature flags based on a version and implements the new 
> watermarks.
> 
> Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>

applied


