From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] X.25: Adds /proc/sys/net/x25/x25_forward to
 control forwarding.
Date: Thu, 08 Feb 2007 13:34:43 -0800 (PST)
Message-ID: <20070208.133443.30185813.davem@davemloft.net>
References: <1170890071.5189.40.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-x25@vger.kernel.org, eis@baty.hanse.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: ahendry@tusc.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42725
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1423433AbXBHVeo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Feb 2007 16:34:44 -0500
In-Reply-To: <1170890071.5189.40.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ahendry <ahendry@tusc.com.au>
Date: Thu, 08 Feb 2007 10:14:31 +1100

> echo "1" > /proc/sys/net/x25/x25_forward 
> To turn on x25_forwarding, defaults to off
> Requires the previous patch.
> 
> Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

Applied.
