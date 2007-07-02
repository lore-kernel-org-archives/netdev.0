From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/9] pasemi_mac: Fix TX interrupt threshold
Date: Mon, 02 Jul 2007 08:37:45 -0400
Message-ID: <4688F199.3030906@pobox.com>
References: <20070622194720.614405000@lixom.net> <20070622200454.GB11723@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51123 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753490AbXGBMhr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2007 08:37:47 -0400
In-Reply-To: <20070622200454.GB11723@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Olof Johansson wrote:
> It was mistakenly set to interrupt on the second packet instead of first, causing
> some interesting latency behaviour.
> 
> 
> Signed-off-by: Olof Johansson <olof@lixom.net>

applied


