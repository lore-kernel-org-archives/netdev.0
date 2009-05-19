From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][be2net] remove napi in the tx path
Date: Mon, 18 May 2009 19:17:53 -0700 (PDT)
Message-ID: <20090518.191753.135843902.davem@davemloft.net>
References: <20090519013616.GA25903@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43792
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752659AbZESCRz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 22:17:55 -0400
In-Reply-To: <20090519013616.GA25903@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitk@serverengines.com>
Date: Tue, 19 May 2009 07:06:20 +0530

> David, I have spun this patch again and against the net-2.6 tree.
> This patch is based on a certain feedback that we got and hence
> it is equally urgent as the previous patch for this to get in the net-2.6
> tree.
> Please consider. I hope this applies cleanly!

This patch does not meet 2.6.30 criteria this late in the release
process.  I will only apply it to net-next-2.6
