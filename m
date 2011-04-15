From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] qlge: make nic_operations struct const
Date: Thu, 14 Apr 2011 21:55:18 -0700 (PDT)
Message-ID: <20110414.215518.71125166.davem@davemloft.net>
References: <20110414085152.042a79e4@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ron.mercer@qlogic.com, netdev@vger.kernel.org,
	linux-driver@qlogic.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53686
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751018Ab1DOEzy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 00:55:54 -0400
In-Reply-To: <20110414085152.042a79e4@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 14 Apr 2011 08:51:52 -0700

> The struct nic_operations is just function pointers and should be
> declared const for added security.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
