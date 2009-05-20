From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH][be2net] remove napi in the tx path and do
 tx completion processing in interrupt context
Date: Wed, 20 May 2009 12:46:37 -0700 (PDT)
Message-ID: <20090520.124637.14514843.davem@davemloft.net>
References: <20090519121056.GB26870@serverengines.com>
	<20090519.151334.87370735.davem@davemloft.net>
	<20090520125609.GG4530@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50791
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755051AbZETTqj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2009 15:46:39 -0400
In-Reply-To: <20090520125609.GG4530@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitk@serverengines.com>
Date: Wed, 20 May 2009 18:26:11 +0530

> We will come back with a proper patch if necessary, after some more analysis.

Thank you.
