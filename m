From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [patch] myri: remove dead code
Date: Mon, 15 Mar 2010 07:19:26 -0400
Message-ID: <4B9E17BE.1080009@myri.com>
References: <20100315082408.GG18181@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Brice Goglin <brice@myri.com>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1792 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S936134Ab0COL5w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Mar 2010 07:57:52 -0400
In-Reply-To: <20100315082408.GG18181@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Carpenter wrote:
> We can never reach the return statement.

Agreed, thanks for pointing that out.

Drew
