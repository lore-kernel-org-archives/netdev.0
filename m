From: David Miller <davem@davemloft.net>
Subject: Re: [TG3]: Workaround MSI bug on 5714/5780.
Date: Sat, 08 Sep 2007 14:25:38 -0700 (PDT)
Message-ID: <20070908.142538.74726815.davem@davemloft.net>
References: <1189105530.4852.8.camel@dell>
	<20070906.125019.104036964.davem@davemloft.net>
	<1189218381.5210.67.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, netdev@vger.kernel.org, ananth@broadcom.com,
	nsankar@broadcom.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:57174
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752913AbXIHVZm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Sep 2007 17:25:42 -0400
In-Reply-To: <1189218381.5210.67.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 07 Sep 2007 19:26:21 -0700

> David, I see that you have already done the revert in your 2.6.23 tree.

I intend to revert that and only push the tg3 fix into
2.6.23

Earlier I had the idea to undo the quirk too, but that's
something I decided was not a good idea.
