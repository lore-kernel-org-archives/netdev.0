From: TAKANO Ryousei <takano@axe-inc.co.jp>
Subject: Re: [RFC][PATCH 1/3] NET_SCHED: PSPacer qdisc module
Date: Thu, 22 Nov 2007 12:06:05 +0900 (JST)
Message-ID: <20071122.120605.56388606.takano@axe-inc.co.jp>
References: <20071121.191840.07671434.takano@axe-inc.co.jp>
	<1195658130.4437.17.camel@localhost>
	<20071122.115433.121501746.takano@axe-inc.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, t.kudoh@aist.go.jp
To: takano-ryousei@aist.go.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from axekw.axe-inc.co.jp ([61.199.217.67]:49422 "EHLO
	axekw.axe-inc.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751919AbXKVDGK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 22:06:10 -0500
In-Reply-To: <20071122.115433.121501746.takano@axe-inc.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I am sorry I send an unfinished mail.

> > Also, the idea of using a PAUSE frame to add gaps is interesting, but
> > you should note that in linux a qdisc may be attached to any network
> > device and this for example maybe a PPP device etc. What would you use
> > for gaps in that case? 
> 
You are right. PSPacer depends on the Ethernet, and it is not pretty
good. Now I do not have any ideas for the other network devices.
Do anyone have any ideas or suggestions?

Best regards,
Ryousei Takano

