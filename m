From: Amit Salecha <amit.salecha@qlogic.com>
Subject: RE: [PATCH 27/49] drivers/net/netxen: Use vzalloc
Date: Fri, 5 Nov 2010 00:18:30 -0500
Message-ID: <99737F4847ED0A48AECC9F4A1974A4B80FCEAB4368@MNEXMB2.qlogic.org>
References: <cover.1288925424.git.joe@perches.com>,<61bf7e82bb35693aebdb3a56b30b1c38836bf502.1288925425.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>, Jiri Kosina <trivial@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexcashub1.qlogic.com ([198.70.193.61]:58327 "EHLO
	avexcashub1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750848Ab0KEFUJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Nov 2010 01:20:09 -0400
In-Reply-To: <61bf7e82bb35693aebdb3a56b30b1c38836bf502.1288925425.git.joe@perches.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Joe Perches [joe@perches.com]
> Sent: Friday, November 05, 2010 8:37 AM
> To: Jiri Kosina
> Cc: Amit Salecha; netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: [PATCH 27/49] drivers/net/netxen: Use vzalloc
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
> drivers/net/netxen/netxen_nic_init.c |    7 ++-----
>  files changed, 2 insertions(+), 5 deletions(-)

Thanks.