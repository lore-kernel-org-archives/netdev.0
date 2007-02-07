From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/4] ucc_geth: Change private immrbar_virt_to_phys to
 generic iopa
Date: Tue, 06 Feb 2007 19:19:01 -0500
Message-ID: <45C91AF5.8090700@garzik.org>
References: <45C86715.6090600@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Li Yang <leoli@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56681 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030297AbXBGATD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Feb 2007 19:19:03 -0500
In-Reply-To: <45C86715.6090600@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Li Yang wrote:
> Get rid of private immrbar_virt_to_phys() routine and
> use generic iopa().
> 
> Signed-off-by: Li Yang <leoli@freescale.com>
> ---
> drivers/net/ucc_geth.c |   29 ++++++-----------------------
> 1 files changed, 6 insertions(+), 23 deletions(-)

I'll await resend pending resolution of comments


