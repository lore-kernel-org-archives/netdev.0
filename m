From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: OT: Re: [PATCH] CAN: add controller hardware name for Softing cards
Date: Mon, 21 Feb 2011 18:26:38 +0100
Message-ID: <4D62A04E.2060702@hartkopp.net>
References: <20110221090421.GF328@e-circ.dyndns.org> <4D622CC1.5050402@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Kurt Van Dijck <kurt.van.dijck@eia.be>, netdev@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>,
	Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:29627 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752459Ab1BUR0h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Feb 2011 12:26:37 -0500
In-Reply-To: <4D622CC1.5050402@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21.02.2011 10:13, Marc Kleine-Budde wrote:
> On 02/21/2011 10:04 AM, Kurt Van Dijck wrote:
>> I just found that the controller hardware name is not set for the Softing
>> driver. After this patch, "$ ip -d link show" looks nicer.
>>
>> Signed-off-by: Kurt Van Dijck <kurt.van.dijck@eia.be>
> Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>
> 

Hello Marc,

i really appreciate your work regarding the CAN driver maintenance together
with Wolfgang!

Would it probably make sense to add your name to the drivers/net/can section
in the MAINTAINERS file so that Dave and the other listeners on netdev-ML can
appraise your Acked-by more easily?

Regards,
Oliver
