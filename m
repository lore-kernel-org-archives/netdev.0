From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] xen-netfront: remove dead code
Date: Tue, 14 Aug 2007 01:52:22 -0400
Message-ID: <46C14316.9090003@garzik.org>
References: <46B8EA9A.5020704@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>, Adrian Bunk <bunk@stusta.de>,
	Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52112 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964953AbXHNFw0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 01:52:26 -0400
In-Reply-To: <46B8EA9A.5020704@goop.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeremy Fitzhardinge wrote:
> This patch removes some residual dead code left over from removing the
> "flip" receive mode.  This patch doesn't change the generated output
> at all, since gcc already realized it was dead.
> 
> This resolves the "regression" reported by Adrian.
> 
> Signed-off-by: Jeremy Fitzhardinge <jeremy@xensource.com>
> Cc: Adrian Bunk <bunk@stusta.de>
> Cc: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

applied


