From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] forcedeth bug fix: realtek phy 8211c errata
Date: Tue, 29 Jul 2008 17:49:31 -0400
Message-ID: <488F906B.5020102@pobox.com>
References: <488A2A11.4080000@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56415 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753257AbYG2Vtl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jul 2008 17:49:41 -0400
In-Reply-To: <488A2A11.4080000@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ayaz Abdulla wrote:
> This patch adds support for the realtek 8211c phy. The driver must 
> perform a hardware reset of the phy due to an errata where the phy could 
> not detect the link.
> 
> Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>

applied


