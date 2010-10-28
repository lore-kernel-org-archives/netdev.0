From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] netxen: fix kdump
Date: Thu, 28 Oct 2010 11:34:24 -0700 (PDT)
Message-ID: <20101028.113424.226785354.davem@davemloft.net>
References: <1288169510-4655-1-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com, rajesh.borundia@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44682
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758225Ab0J1SeB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 14:34:01 -0400
In-Reply-To: <1288169510-4655-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Date: Wed, 27 Oct 2010 01:51:50 -0700

> From: Rajesh Borundia <rajesh.borundia@qlogic.com>
> 
> Reset the whole hw instead of freeing hw resources
> consumed by each pci function.
> 
> Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
> Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>

Applied, thanks.
