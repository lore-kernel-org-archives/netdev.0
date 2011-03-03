From: David Miller <davem@davemloft.net>
Subject: Re: r8169 disable ASPM patch
Date: Thu, 03 Mar 2011 11:54:08 -0800 (PST)
Message-ID: <20110303.115408.260106040.davem@davemloft.net>
References: <20110302.215255.183067695.davem@davemloft.net>
	<20110303094518.GA13491@electric-eye.fr.zoreil.com>
	<A671CA7371854B808BAB6DA0BA7B050B@realtek.com.tw>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org, sgruszka@redhat.com
To: hayeswang@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48926
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932185Ab1CCTxb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 14:53:31 -0500
In-Reply-To: <A671CA7371854B808BAB6DA0BA7B050B@realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: hayeswang <hayeswang@realtek.com>
Date: Thu, 3 Mar 2011 19:35:11 +0800

> Our hardware engineer says that it has an issue indeed for 8111B (that is, rev
> 01) when the aspm is enabled. For the other chips, the aspm would affect the
> performance. We suggest to disable for stablity.

Ok, I will apply Stanislaw's patch, thanks.
