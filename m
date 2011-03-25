From: David Miller <davem@davemloft.net>
Subject: synchronous netlink
Date: Thu, 24 Mar 2011 20:55:49 -0700 (PDT)
Message-ID: <20110324.205549.186286411.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42672
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750917Ab1CYDzL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2011 23:55:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Patrick, just a reminder that we have to deal with that
connector regression that exists ever since you added code
to netlink which assumes synchronous processing.

Thanks.
