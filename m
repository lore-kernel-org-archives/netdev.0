From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] TCP sysctl documentation: tcp_moderate_rcvbuf
Date: Tue, 27 Feb 2007 10:05:40 -0800 (PST)
Message-ID: <20070227.100540.48528396.davem@davemloft.net>
References: <45E384CC.2090004@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jheffner@psc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41847
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751949AbXB0SFm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Feb 2007 13:05:42 -0500
In-Reply-To: <45E384CC.2090004@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Heffner <jheffner@psc.edu>
Date: Mon, 26 Feb 2007 20:09:32 -0500

> Document sysctl tcp_moderate_rcvbuf.
> 
> Signed-off-by: John Heffner <jheffner@psc.edu>

Thanks John.

I rolled all 3 patches into one commit and applied to
net-2.6 GIT.

Thanks again!
