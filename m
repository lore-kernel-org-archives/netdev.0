From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH-mm 5/8] typhoon: remove uses of __constant_{endian}
	helpers
Date: Wed, 26 Nov 2008 18:08:30 -0500
Message-ID: <1227740910.25756.0.camel@obelisk.thedillows.org>
References: <1227733972.5511.127.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jeff@garzik.org>,
	David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.knology.net ([24.214.63.101]:32856 "EHLO smtp.knology.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752276AbYKZXPO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Nov 2008 18:15:14 -0500
In-Reply-To: <1227733972.5511.127.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-11-26 at 13:12 -0800, Harvey Harrison wrote:
> The base versions handle constant folding just fine.
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>

Acked-by: David Dillow <dave@thedillows.org>

