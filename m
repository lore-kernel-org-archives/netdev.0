From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 10/12] forcedeth: tx max work
Date: Tue, 23 Jan 2007 17:53:26 -0500
Message-ID: <45B691E6.7040409@pobox.com>
References: <45B63F48.10607@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51553 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965517AbXAWWxh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jan 2007 17:53:37 -0500
To: Ayaz Abdulla <aabdulla@nvidia.com>
In-Reply-To: <45B63F48.10607@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ayaz Abdulla wrote:
> This patch adds a limit to how much tx work can be done in each
> iteration of tx processing. If the max limit is reached, remaining tx 
> completions will be handled by timer interrupt.
> 
> Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>

Thanks, will apply soon.

Please resend patches 11 & 12 too.  Whereever I stop applying patches, 
in a patch series, the remaining patches are dropped.

I either apply a patch immediately, or delete it.

	Jeff


