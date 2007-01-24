From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 10/12] forcedeth: tx max work
Date: Wed, 24 Jan 2007 02:17:11 -0500
Message-ID: <45B707F7.3020402@pobox.com>
References: <45B63F48.10607@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54238 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932936AbXAXHRZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Jan 2007 02:17:25 -0500
In-Reply-To: <45B63F48.10607@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ayaz Abdulla wrote:
> This patch adds a limit to how much tx work can be done in each
> iteration of tx processing. If the max limit is reached, remaining tx 
> completions will be handled by timer interrupt.
> 
> Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>

applied 10-12


