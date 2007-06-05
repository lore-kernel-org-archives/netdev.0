From: David Miller <davem@davemloft.net>
Subject: Re: [RFC DUMMY 07/09]: Use rtnl_link API
Date: Tue, 05 Jun 2007 12:46:31 -0700 (PDT)
Message-ID: <20070605.124631.68158119.davem@davemloft.net>
References: <20070605141250.15650.47178.sendpatchset@localhost.localdomain>
	<20070605141301.15650.47999.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, socketcan@hartkopp.net, hadi@cyberus.ca,
	xemul@sw.ru, ebiederm@xmission.com, tgraf@suug.ch
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47997
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756281AbXFETqR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 15:46:17 -0400
In-Reply-To: <20070605141301.15650.47999.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Tue,  5 Jun 2007 16:13:02 +0200 (MEST)

> [DUMMY]: Use rtnl_link API
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

This looks good too.

I'll let folks like Jamal and Ben look over the IFB and
VLAN bits.

Thanks for doing this work Patrick!
