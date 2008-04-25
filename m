From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] forcedeth: realtek phy crossover detection
Date: Fri, 25 Apr 2008 02:04:33 -0400
Message-ID: <48117471.50601@pobox.com>
References: <480F81EA.1050005@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57247 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755450AbYDYGEk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Apr 2008 02:04:40 -0400
In-Reply-To: <480F81EA.1050005@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ayaz Abdulla wrote:
> This patch fixes an issue seen with the realtek 8201 phy. This phy has a 
> problem with crossover detection and it needs to be disabled. The 
> problem only arises on certain switches. Therefore, a module parameter 
> has been added to allow enabling crossover detection if needed. The 
> default will be set to disabled.
> 
> 
> Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>

applied


