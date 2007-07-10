From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] Fix typo in drivers/net/s2io.c
Date: Tue, 10 Jul 2007 12:25:47 -0400
Message-ID: <4693B30B.5010003@garzik.org>
References: <200707101158.03730.eike-kernel@sf-tec.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linas Vepstas <linas@austin.ibm.com>,
	Ramkrishna Vepa <Ramkrishna.Vepa@neterion.com>,
	Raghavendra Koushik <raghavendra.koushik@neterion.com>,
	Wen Xiong <wenxiong@us.ibm.com>, netdev@vger.kernel.org
To: Rolf Eike Beer <eike-kernel@sf-tec.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59972 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760121AbXGJQZ7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 12:25:59 -0400
In-Reply-To: <200707101158.03730.eike-kernel@sf-tec.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rolf Eike Beer wrote:
> Introduced in d796fdb708fc5b10112934cba43e832c36ce4923.
> 
> Signed-off-by: Rolf Eike Beer <eike-kernel@sf-tec.de>
> 
> ---
> commit 58056c2424917e90b86ca11c2c5d3fd35313d7b6
> tree 854d63a14f96416aad64d12ea71cb331acfcc7db
> parent 87a2df362631d53fdc169a5d76969365aff69c10
> author Rolf Eike Beer <eike-kernel@sf-tec.de> Tue, 10 Jul 2007 11:55:46 +0200
> committer Rolf Eike Beer <eike-kernel@sf-tec.de> Tue, 10 Jul 2007 11:55:46 
> +0200
> 
>  drivers/net/s2io.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
> index 2d826ff..fa29a40 100644
> --- a/drivers/net/s2io.c
> +++ b/drivers/net/s2io.c
> @@ -8036,7 +8036,7 @@ static void lro_append_pkt(struct s2io_nic *sp, struct 
> lro *lro,
>  /**
>   * s2io_io_error_detected - called when PCI error is detected
>   * @pdev: Pointer to PCI device
> - * @state: The current pci conneection state
> + * @state: The current pci connection state

applied manually, patch was corrupted


