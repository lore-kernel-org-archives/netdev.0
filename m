From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 10/10] pxa: make littleton to use the new smc91x platform
 data
Date: Fri, 27 Jun 2008 01:58:07 -0400
Message-ID: <4864816F.5070407@garzik.org>
References: <> <1214300867-15495-11-git-send-email-eric.y.miao@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel <linux-arm-kernel@lists.arm.linux.org.uk>,
	linux-netdev <netdev@vger.kernel.org>,
	Nicolas Pitre <nico@cam.org>,
	Magnus Damm <magnus.damm@gmail.com>,
	Eric Miao <eric.miao@marvell.com>
To: Eric Miao <eric.y.miao@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55547 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752565AbYF0F6K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jun 2008 01:58:10 -0400
In-Reply-To: <1214300867-15495-11-git-send-email-eric.y.miao@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Miao wrote:
> From: Eric Miao <eric.miao@marvell.com>
> 
> Signed-off-by: Eric Miao <eric.miao@marvell.com>
> ---
>  arch/arm/mach-pxa/littleton.c |    9 +++++++++
>  drivers/net/smc91x.h          |    3 ++-
>  2 files changed, 11 insertions(+), 1 deletions(-)

The rest of the patches seem OK.

What do ARM people prefer -- should I ACK this series, and let it be 
merged via an ARM tree?

The series is mainly platform-oriented rather than net-oriented.


