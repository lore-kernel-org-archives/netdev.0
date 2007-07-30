From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RESEND 1/2] netxen: re-init station address after h/w init
Date: Mon, 30 Jul 2007 15:52:08 -0400
Message-ID: <46AE4168.3000506@garzik.org>
References: <20070725144310.500691352@netxen.com> <20070725144515.533385702@netxen.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rob@netxen.com
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51961 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965150AbXG3TwL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jul 2007 15:52:11 -0400
In-Reply-To: <20070725144515.533385702@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dhananjay@netxen.com wrote:
> This is a workaround for firmware bug with 2nd port of multiport adapter,
> where MAC address is reset. Driver just needs to overwrite it with the
> value read from PROM.
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

applied 1-2


