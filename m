From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] kaweth: Clean up code
Date: Mon, 13 Apr 2009 15:46:10 -0700 (PDT)
Message-ID: <20090413.154610.231691640.davem@davemloft.net>
References: <49de2c5b.LWVli5E5/g9YVwyP%Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Larry.Finger@lwfinger.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42826
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750750AbZDMWqT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2009 18:46:19 -0400
In-Reply-To: <49de2c5b.LWVli5E5/g9YVwyP%Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Larry Finger <Larry.Finger@lwfinger.net>
Date: Thu, 09 Apr 2009 12:11:55 -0500

> The driver kaweth yields a -EBUSY error when starting, and a -ETIME
> error when shutting down. These errors are avoided, and the RX status
> is further checked for other potential errors.
> 
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>

Applied, thanks.
