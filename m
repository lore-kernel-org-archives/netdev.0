From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] qlcnic: fix set mac addr
Date: Wed, 07 Apr 2010 16:51:56 -0700 (PDT)
Message-ID: <20100407.165156.168164798.davem@davemloft.net>
References: <1270638114-15323-1-git-send-email-amit.salecha@qlogic.com>
	<1270638114-15323-2-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48216
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753199Ab0DGXvx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 19:51:53 -0400
In-Reply-To: <1270638114-15323-2-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Date: Wed,  7 Apr 2010 04:01:54 -0700

> If interface is down, mac address request are not sent to fw
> but it is getting add in driver mac list.
> Driver mac list should be in sync with fw i.e addresses communicated
> to fw.
> 
> Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>

Applied, thanks.
