From: David Miller <davem@davemloft.net>
Subject: Re: [1/1] connector: Bugfix for cn_call_callback()
Date: Wed, 07 Mar 2007 12:55:56 -0800 (PST)
Message-ID: <20070307.125556.78708484.davem@davemloft.net>
References: <20070307121030.GA19089@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: philipp.reisner@linbit.com, lars.ellenberg@linbit.com,
	netdev@vger.kernel.org
To: johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32856
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S2992567AbXCGUz6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2007 15:55:58 -0500
In-Reply-To: <20070307121030.GA19089@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Wed, 7 Mar 2007 15:10:30 +0300

> When system under heavy stress and must allocate new work
> instead of reusing old one, new work must use correct 
> completion callback.
> 
> Patch is based on Philipp's and Lars' work.
> I only cleaned small stuff (and removed spaces instead of tabs).
> 
> Signed-off-by: Philipp Reisner <philipp.reisner@linbit.com>
> Signed-off-by: Lars Ellenberg <lars.ellenberg@linbit.com>
> Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

Applied, thank you.
