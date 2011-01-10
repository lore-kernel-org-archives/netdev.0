From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] qlcnic: change module parameter permissions
Date: Mon, 10 Jan 2011 13:35:14 -0800 (PST)
Message-ID: <20110110.133514.35822175.davem@davemloft.net>
References: <1294654523-3085-1-git-send-email-amit.salecha@qlogic.com>
	<1294654523-3085-4-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37346
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754922Ab1AJVem (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 16:34:42 -0500
In-Reply-To: <1294654523-3085-4-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Date: Mon, 10 Jan 2011 02:15:23 -0800

> o Updating module parameter after driver load is not supported
>   except auto_fw_reset parameter. Changing these parameter after
>   driver load, can have weird result.
> 
> o Update driver version to 5.0.15.
> 
> Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>

Applied.
