From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 V3] kaweth: Clean up code
Date: Thu, 02 Apr 2009 01:10:15 -0700 (PDT)
Message-ID: <20090402.011015.152622937.davem@davemloft.net>
References: <49d3885f.OXwftgx2/UvY0Tex%Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	oliver@neukum.org
To: Larry.Finger@lwfinger.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33807
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754835AbZDBIK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 04:10:26 -0400
In-Reply-To: <49d3885f.OXwftgx2/UvY0Tex%Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Larry Finger <Larry.Finger@lwfinger.net>
Date: Wed, 01 Apr 2009 10:29:35 -0500

> The driver kaweth yields a -EBUSY error when starting, and a -ETIME
> error when shutting down. These errors are avoided, and the RX status
> is further checked for other potential errors.
> 
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> ---
> 
> DaveM,
> 
> This is 2.6.31 material as the imain change is to eliminate two trivial
> log messages.

Larry, please resubmit this to me when -rc1 is released.

Thanks!
