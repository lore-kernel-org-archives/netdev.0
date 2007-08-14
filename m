From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [2.6 patch] remove Documentation/networking/net-modules.txt
Date: Tue, 14 Aug 2007 18:04:01 -0400
Message-ID: <46C226D1.4070203@pobox.com>
References: <20070814212604.GW18945@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47423 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935617AbXHNWEO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 18:04:14 -0400
In-Reply-To: <20070814212604.GW18945@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> According to git, the only one who touched this file during the last
> 5 years was me when removing drivers...
> 
> modinfo offers less ancient information.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>
> 
> ---
> 
> This patch has been sent on:
> - 23 Jul 2007
> 
>  Documentation/networking/00-INDEX        |    2 
>  Documentation/networking/net-modules.txt |  315 -----------------------
>  2 files changed, 317 deletions(-)

NAK, IMO it's still use for ancient drivers


