From: Marc Pignat <marc.pignat@hevs.ch>
Subject: Re: [PATCH v2] at91_ether: use netstats in net_device structure
Date: Thu, 8 May 2008 17:40:09 +0200
Message-ID: <200805081740.10061.marc.pignat@hevs.ch>
References: <4820572E.7010304@teltonika.lt>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>,
	netdev@vger.kernel.org, linux@maxim.org.za
To: linux-arm-kernel@lists.arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.hevs.ch ([153.109.23.10]:57081 "EHLO mail.hevs.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752961AbYEHPkP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 May 2008 11:40:15 -0400
In-Reply-To: <4820572E.7010304@teltonika.lt>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 06 May 2008, Paulius Zaleckas wrote:
> Use net_device_stats from net_device structure instead of local.
> 
> v2: Removed unused variable 'lp' in at91ether_stats function.
> 
> Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
> Tested-by: Marc Pignat <marc.pignat@hevs.ch>
> 
Ok, new patch tested and added Andrew to the CC (he is the at91 maintainer).

Regards

Marc

