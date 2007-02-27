From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/3] forcedeth: fixed missing call in napi poll
Date: Tue, 27 Feb 2007 04:16:18 -0500
Message-ID: <45E3F6E2.7030908@garzik.org>
References: <45DAB296.8040609@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47372 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752487AbXB0JQd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Feb 2007 04:16:33 -0500
In-Reply-To: <45DAB296.8040609@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ayaz Abdulla wrote:
> The napi poll routine was missing the call to the optimized rx process 
> routine. This patch adds the missing call for the optimized path.
> 
> Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>

applied 1-3


