From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH 1/1] net: mvneta: Remove unneeded version.h header
 inclusion
Date: Mon, 3 Dec 2012 19:58:26 +0100
Message-ID: <20121203195826.679f70d4@skate>
References: <1354527928-27472-1-git-send-email-sachin.kamat@linaro.org>
	<20121203.134620.972752091312747013.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: sachin.kamat@linaro.org, netdev@vger.kernel.org, patches@linaro.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([88.190.12.23]:59648 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751921Ab2LCS6l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2012 13:58:41 -0500
In-Reply-To: <20121203.134620.972752091312747013.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear David Miller,

On Mon, 03 Dec 2012 13:46:20 -0500 (EST), David Miller wrote:
> From: Sachin Kamat <sachin.kamat@linaro.org>
> Date: Mon,  3 Dec 2012 15:15:28 +0530
> 
> > linux/version.h inclusion is not necessary.
> > 
> > Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
> 
> Acked-by: David S. Miller <davem@davemloft.net>
> 
> I hope the mvneta folks will pick this up and apply it where it
> needs to be as the mvneta driver isn't in the net-next tree.

Yes, I will pick it up, and send a pull request to the Marvell
maintainers. I have other mvneta fixes that I'll send together with
this one.

Thanks,

Thomas
-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
