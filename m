From: David Miller <davem@davemloft.net>
Subject: Re: [SKFILTER]: Add SKF_ADF_NLATTR instruction
Date: Thu, 10 Apr 2008 02:10:36 -0700 (PDT)
Message-ID: <20080410.021036.192893004.davem@davemloft.net>
References: <47F22B2A.2000209@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, hadi@cyberus.ca, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37843
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752789AbYDJJKf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 05:10:35 -0400
In-Reply-To: <47F22B2A.2000209@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 01 Apr 2008 14:31:38 +0200

> This patch on top of Stephens netlink filter patches add
> a new filter instruction for locating netlink attributes.
> An example how it is used is contained in the changelog
> entry.

Applied to net-2.6.26, thanks Patrick!
