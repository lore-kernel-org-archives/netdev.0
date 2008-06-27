From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 01/10] smc91x: remove unused code enclosed by #ifdef CONFIG_ISA
 .. #endif
Date: Fri, 27 Jun 2008 01:55:50 -0400
Message-ID: <486480E6.8070804@garzik.org>
References: <> <1214300867-15495-2-git-send-email-eric.y.miao@gmail.com>
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
Received: from srv5.dvmed.net ([207.36.208.214]:55531 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752392AbYF0Fzz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jun 2008 01:55:55 -0400
In-Reply-To: <1214300867-15495-2-git-send-email-eric.y.miao@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Miao wrote:
> Apparently, the code enclosed by #ifdef CONFIG_ISA .. #endif are no longer
> used

What does this mean?

CONFIG_ISA platforms still exist, and one presumes that the ISA hardware 
still exists.

Is this hardware covered by another driver?

