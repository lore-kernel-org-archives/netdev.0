From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 5/7] sky2: enable IRQ on duplex renegotiation
Date: Wed, 30 May 2007 09:54:44 -0400
Message-ID: <465D8224.9040905@garzik.org>
References: <20070524222242.555399884@linux-foundation.org> <20070524222538.725354382@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:33860 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751974AbXE3Nyq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 May 2007 09:54:46 -0400
In-Reply-To: <20070524222538.725354382@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Don't want IRQ on FIFO error because there is nothing useful to do with it.
> But do want IRQ on duplex change.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

applied


