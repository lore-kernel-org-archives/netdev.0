From: chunkeey@web.de
Subject: Re: [PATCH wireless-2.6-git] prism54: WPA/RSN support for fullmac cards
Date: Fri, 24 Nov 2006 16:55:50 +0100
Message-ID: <200611241655.50302.chunkeey@web.de>
References: <200610031457.33215.chunkeey@web.de> <200611181118.02549.chunkeey@web.de> <200611220201.34717.dtor@insightbb.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate01.web.de ([217.72.192.221]:57049 "EHLO
	fmmailgate01.web.de") by vger.kernel.org with ESMTP
	id S1755791AbWKXPzw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Nov 2006 10:55:52 -0500
Received: from smtp08.web.de (fmsmtp08.dlan.cinetic.de [172.20.5.216])
	by fmmailgate01.web.de (Postfix) with ESMTP id 633753D4A78F
	for <netdev@vger.kernel.org>; Fri, 24 Nov 2006 16:55:51 +0100 (CET)
Received: from [87.181.127.236] (helo=debian64.daheim)
	by smtp08.web.de with asmtp (TLSv1:AES256-SHA:256)
	(WEB.DE 4.107 #114)
	id 1GndP5-0003MV-00
	for netdev@vger.kernel.org; Fri, 24 Nov 2006 16:55:51 +0100
Received: from localhost.localdomain
	([127.0.0.1] helo=localhost ident=chuck)
	by debian64.daheim with esmtpa (Exim 4.63)
	(envelope-from <chunkeey@web.de>)
	id 1GndP4-0001iO-HT
	for netdev@vger.kernel.org; Fri, 24 Nov 2006 16:55:50 +0100
To: netdev@vger.kernel.org
In-Reply-To: <200611220201.34717.dtor@insightbb.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday, 22. November 2006 08:01, you wrote:
>
> Hmm, something funky is going on with my hotplug scripts - if I rerun
> ifup eth1 after inserting the card it associates just fine. Sorry for
> the false alarm, the drivers seems to be working fine.
>
> Still not sure why old driver does not need second "ifup"...

old drivers? which one? the svn? 2.6.18?

Since, the card doesn't associate with WPA protected wlans automaticlly,
but what about WEP or unprotected wlans? 

It would be nice if someone can capture the MLME frames and look
if the card does the right thing.

