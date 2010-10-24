From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/12] last of the namespace cleanups
Date: Sun, 24 Oct 2010 15:20:30 -0700 (PDT)
Message-ID: <20101024.152030.115921890.davem@davemloft.net>
References: <20101021175045.625707607@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56840
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933030Ab0JXWUH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Oct 2010 18:20:07 -0400
In-Reply-To: <20101021175045.625707607@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 21 Oct 2010 10:50:45 -0700

> These are the last of the cleanups to networking for 2.6.37 based
> on "make namespacecheck" reports.

All applied except the ipconfig patch that breaks the sparc build.

Thanks.
