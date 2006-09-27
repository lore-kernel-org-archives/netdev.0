From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 3/4] ethtool: don't show sync queue's on skge/sky2
Date: Wed, 27 Sep 2006 19:03:33 -0400
Message-ID: <451B0345.50504@pobox.com>
References: <20060926115437.11ed1f85@freekitty>	<451AF4B1.2000208@pobox.com> <20060926131000.08a67c89@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:5325 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1031196AbWI0XDf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 19:03:35 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060926131000.08a67c89@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Remove printout of synchronous transmit queue info because
> it is unused by the driver.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

NAK, it doesn't matter whether a feature is used by the driver or not.


