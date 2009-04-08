From: David Miller <davem@davemloft.net>
Subject: Re: [patch] nui.c error handling
Date: Wed, 08 Apr 2009 15:44:13 -0700 (PDT)
Message-ID: <20090408.154413.40860574.davem@davemloft.net>
References: <alpine.DEB.2.00.0904081437400.32632@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46822
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754872AbZDHWoW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2009 18:44:22 -0400
In-Reply-To: <alpine.DEB.2.00.0904081437400.32632@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Wed, 8 Apr 2009 14:39:28 +0300 (EAT)

> platform_device_register_simple() returns ERR_PTR(), not NULL, if an error 
> occurs.
> 
> Found by smatch (http://repo.or.cz/w/smatch.git).  Compile tested.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied, thanks.
