From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: cancel work queue when interface goes down
Date: Mon, 22 Jul 2013 01:11:01 +0200
Message-ID: <20130721231101.GA12377@electric-eye.fr.zoreil.com>
References: <1574882.LCoXNHVmA8@al>
 <20130721183551.GA10925@electric-eye.fr.zoreil.com>
 <3140279.qh57ADNKhO@al>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>
To: Peter Wu <lekensteyn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:45265 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751907Ab3GUXLR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jul 2013 19:11:17 -0400
Content-Disposition: inline
In-Reply-To: <3140279.qh57ADNKhO@al>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Wu <lekensteyn@gmail.com> :
[...]
> Thanks for your feedback, I have attached a more concise summary of the actual
> problem on the bottom of this message.

Please cut the commit message lines around 72 cols send it as a
[PATCH net v2 1/1] ... with:

Acked-by: Francois Romieu <romieu@fr.zoreil.com>

Thanks.

-- 
Ueimor
