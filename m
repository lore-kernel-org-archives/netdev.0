From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 3/4] ethtool: don't show sync queue's on skge/sky2
Date: Wed, 27 Sep 2006 15:34:49 -0700
Message-ID: <20060927153449.695a0f09@freekitty>
References: <20060926115437.11ed1f85@freekitty>
	<451AF4B1.2000208@pobox.com>
	<20060926131000.08a67c89@freekitty>
	<451B0345.50504@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:59329 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1031237AbWI0XRa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 19:17:30 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <451B0345.50504@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 27 Sep 2006 19:03:33 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> Stephen Hemminger wrote:
> > Remove printout of synchronous transmit queue info because
> > it is unused by the driver.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
> 
> NAK, it doesn't matter whether a feature is used by the driver or not.

Okay, but it's just noise.

-- 
Stephen Hemminger <shemminger@osdl.org>
