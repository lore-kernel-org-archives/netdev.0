From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] dmfe: check pci_alloc_consistent errors
Date: Mon, 27 Oct 2008 14:52:21 -0400
Message-ID: <49060DE5.5080608@garzik.org>
References: <20081023180005A.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53072 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751838AbYJ0Sw1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2008 14:52:27 -0400
In-Reply-To: <20081023180005A.fujita.tomonori@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

FUJITA Tomonori wrote:
> We need to check the address that pci_alloc_consistent() returns since
> it might fail.
> 
> Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
> ---
>  drivers/net/tulip/dmfe.c |   12 +++++++++++-
>  1 files changed, 11 insertions(+), 1 deletions(-)

applied


