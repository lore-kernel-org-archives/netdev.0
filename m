From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] [net/core] merge dev_unicast_discard and
 dev_mc_discard into one
Date: Wed, 18 Jul 2007 02:12:21 -0700 (PDT)
Message-ID: <20070718.021221.84974075.davem@davemloft.net>
References: <11846606051099-git-send-email-crquan@gmail.com>
	<11847264651509-git-send-email-crquan@gmail.com>
	<11847264751175-git-send-email-crquan@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, kaber@coreworks.de, linux-kernel@vger.kernel.org
To: crquan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45885
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752289AbXGRJMW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 05:12:22 -0400
In-Reply-To: <11847264751175-git-send-email-crquan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Denis Cheng <crquan@gmail.com>
Date: Wed, 18 Jul 2007 10:41:04 +0800

> this two functions could share the dev->_xmit_lock acquired context.
> 
> Signed-off-by: Denis Cheng <crquan@gmail.com>

Applied, thanks.
