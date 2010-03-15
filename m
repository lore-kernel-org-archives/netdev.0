From: David Miller <davem@davemloft.net>
Subject: Re: [patch] myri: remove dead code
Date: Mon, 15 Mar 2010 16:06:53 -0700 (PDT)
Message-ID: <20100315.160653.34915355.davem@davemloft.net>
References: <20100315082408.GG18181@bicker>
	<4B9E17BE.1080009@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: error27@gmail.com, brice@myri.com, kaber@trash.net,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: gallatin@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42744
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S937057Ab0COXGb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Mar 2010 19:06:31 -0400
In-Reply-To: <4B9E17BE.1080009@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Gallatin <gallatin@myri.com>
Date: Mon, 15 Mar 2010 07:19:26 -0400

> Dan Carpenter wrote:
>> We can never reach the return statement.
> 
> Agreed, thanks for pointing that out.

Applied, thanks everyone.
