From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.29 forcedeth hang W/O NAPI enabled
Date: Wed, 25 Mar 2009 17:08:43 -0700 (PDT)
Message-ID: <20090325.170843.196352151.davem@davemloft.net>
References: <332981.79226.qm@web57706.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, berkley@cs.wustl.edu
To: adam_richter2004@yahoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33989
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751004AbZCZAIz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 20:08:55 -0400
In-Reply-To: <332981.79226.qm@web57706.mail.re3.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Adam Richter <adam_richter2004@yahoo.com>
Date: Wed, 25 Mar 2009 17:06:03 -0700 (PDT)

> In addition to seeing the problem with CONFIG_FORCEDETH_NAPI
> disabled, I have now reproduced the problem with that configuration
> option enabled.  So, NAPI might not be the problem at all.

Adam, first of all, you don't need to subscribe then unsubscribe
from this mailing list just to post your report.  I just saw you
do that.

We're not nazis and you can post to this mailing list without being a
member.  :-)

Second of all, please look at my reply to your original report,
there is a patch there for you to test.
