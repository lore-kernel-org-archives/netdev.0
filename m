From: David Miller <davem@davemloft.net>
Subject: Re: tcp congestion policy selection link order fragile
Date: Mon, 18 Sep 2006 11:53:09 -0700 (PDT)
Message-ID: <20060918.115309.88343320.davem@davemloft.net>
References: <20060918095936.GA6161@outpost.ds9a.nl>
	<20060918.070600.107685035.davem@davemloft.net>
	<20060918154048.GA18240@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:2241
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751810AbWIRSxJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Sep 2006 14:53:09 -0400
To: bert.hubert@netherlabs.nl
In-Reply-To: <20060918154048.GA18240@outpost.ds9a.nl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: bert hubert <bert.hubert@netherlabs.nl>
Date: Mon, 18 Sep 2006 17:40:48 +0200

> What would the desired default be, 'BIC' in all cases?

And if BIC is not enabled in the configuration, then what?
