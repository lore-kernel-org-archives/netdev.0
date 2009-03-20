From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] smsc911x: define status word positions as constants
Date: Thu, 19 Mar 2009 23:59:41 -0700 (PDT)
Message-ID: <20090319.235941.50593963.davem@davemloft.net>
References: <1237458286-23421-1-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ian.saturley@smsc.com
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45334
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751032AbZCTG7y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 02:59:54 -0400
In-Reply-To: <1237458286-23421-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@smsc.com>
Date: Thu, 19 Mar 2009 10:24:44 +0000

> The vast majority of bit constants in this driver are defined in the
> header file, but TX and RX status word bits are not.  This patch (which
> should make no functional change) defines these, to make the driver
> slightly more readable.
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>

Applied.
