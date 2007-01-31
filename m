From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 4/5] sky2: software rx/tx stats
Date: Wed, 31 Jan 2007 05:04:00 -0500
Message-ID: <45C06990.8040503@garzik.org>
References: <20070126193835.658962000@linux-foundation.org> <20070126194004.281546000@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55373 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932933AbXAaKEB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jan 2007 05:04:01 -0500
In-Reply-To: <20070126194004.281546000@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

shemminger@linux-foundation.org wrote:
> Maintain packet statistics in software rather than hardware.
> This is slightly slower, but allows easier debugging of problems
> where packets are still being received by PHY but not being handled
> by hardware.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

applied

