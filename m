From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 10/12] forcedeth: tx max work
Date: Tue, 23 Jan 2007 01:09:40 -0500
Message-ID: <45B5A6A4.3070800@pobox.com>
References: <45B3F307.8060900@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45603 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933039AbXAWGJq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jan 2007 01:09:46 -0500
To: Ayaz Abdulla <aabdulla@nvidia.com>
In-Reply-To: <45B3F307.8060900@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ayaz Abdulla wrote:
> This patch adds a limit to how much tx work can be done in each
> iteration of tx processing. If the max limit is reached, remaining tx 
> completions will be handled by timer interrupt.
> 
> Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>

you attached the entire driver, rather than a patch :)


