From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [1/3] 8139too: Make PIO/MMIO a runtime decision through a module
 parameter.
Date: Tue, 22 Jul 2008 18:02:51 -0400
Message-ID: <4886590B.7050507@garzik.org>
References: <200807152354.m6FNsrk1026943@gelk.kernelslacker.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53284 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753341AbYGVWCy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2008 18:02:54 -0400
In-Reply-To: <200807152354.m6FNsrk1026943@gelk.kernelslacker.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave Jones wrote:
> This is needed to support devices that only work with PIO without penalising devices
> that work fine with MMIO in distro kernels.   It also allows us to eventually
> use PIO as a fallback when setting up MMIO fails.
> 
> Signed-off-by: Dave Jones <davej@redhat.com>

applied 1-3


