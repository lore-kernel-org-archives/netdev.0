From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][NET_SCHED] Make HTB scheduler work with TSO.
Date: Mon, 09 Jul 2007 15:15:22 -0700 (PDT)
Message-ID: <20070709.151522.52166816.davem@davemloft.net>
References: <Pine.LNX.4.63.0706121647280.4120@ranjit.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ranjitm@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38612
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753625AbXGIWPA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 18:15:00 -0400
In-Reply-To: <Pine.LNX.4.63.0706121647280.4120@ranjit.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ranjit Manomohan <ranjitm@google.com>
Date: Tue, 12 Jun 2007 16:53:21 -0700 (PDT)

> Currently the HTB scheduler does not correctly account for TSO packets 
> which causes large inaccuracies in the bandwidth control when using TSO.
> This patch allows the HTB scheduler to work with TSO enabled devices.
> 
> Signed-off-by: Ranjit Manomohan <ranjitm@google.com>

Your patch has much white-space damage and therefore won't apply,
please fix this up and resubmit, thanks.
