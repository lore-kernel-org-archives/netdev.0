From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] cxgb4: configure HW VLAN extraction
 through FW
Date: Wed, 12 May 2010 23:32:49 -0700 (PDT)
Message-ID: <20100512.233249.245390694.davem@davemloft.net>
References: <1273543089-10938-1-git-send-email-dm@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dm@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45064
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754427Ab0EMGck (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 May 2010 02:32:40 -0400
In-Reply-To: <1273543089-10938-1-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dimitris Michailidis <dm@chelsio.com>
Date: Mon, 10 May 2010 18:58:07 -0700

> HW VLAN extraction needs to be configured through FW to work correctly in
> virtualization environments.  Remove the direct register manipulation and
> rely on FW.
> 
> Signed-off-by: Dimitris Michailidis <dm@chelsio.com>

Applied.
