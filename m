From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/4] netxen: fix portnum for hp mezz cards
Date: Tue, 17 Jun 2008 23:25:56 -0400
Message-ID: <48588044.3020805@garzik.org>
References: <> <1213595986-1929-2-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dhananjay Phadke <dhananjay@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40526 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756559AbYFRDZ7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 23:25:59 -0400
In-Reply-To: <1213595986-1929-2-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dhananjay Phadke wrote:
> This fixes a the issue where logical port number is set incorrectly
> for HP blade mezz cards.
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
> ---
>  drivers/net/netxen/netxen_nic_main.c |   10 ++++++++--
>  1 files changed, 8 insertions(+), 2 deletions(-)

applied


