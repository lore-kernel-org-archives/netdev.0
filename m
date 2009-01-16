From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH] typhoon: replace users of __constant_{endian}
Date: Thu, 15 Jan 2009 22:18:04 -0500
Message-ID: <1232075884.1502.0.camel@obelisk.thedillows.org>
References: <1232066488.11986.5.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.knology.net ([24.214.63.101]:37175 "EHLO smtp.knology.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753892AbZAPDYs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2009 22:24:48 -0500
In-Reply-To: <1232066488.11986.5.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-01-15 at 16:41 -0800, Harvey Harrison wrote:
> The base versions handle constant folding just fine, use them
> directly.
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
Acked-by: David Dillow <dave@thedillows.org>

