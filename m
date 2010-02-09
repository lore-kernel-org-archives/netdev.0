From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/sched: Fix module name in Kconfig
Date: Mon, 08 Feb 2010 22:41:51 -0800 (PST)
Message-ID: <20100208.224151.60712062.davem@davemloft.net>
References: <1265478049-29736-1-git-send-email-jluebbe@debian.org>
	<1265574348.3688.37.camel@bigi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jluebbe@debian.org, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59481
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751999Ab0BIGlh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2010 01:41:37 -0500
In-Reply-To: <1265574348.3688.37.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jamal <hadi@cyberus.ca>
Date: Sun, 07 Feb 2010 15:25:48 -0500

> On Sat, 2010-02-06 at 18:40 +0100, Jan Luebbe wrote:
>> The action modules have been prefixed with 'act_', but the Kconfig
>> description was not changed.
>> 
>> Signed-off-by: Jan Luebbe <jluebbe@debian.org>
> 
> Acked-by: Jamal Hadi Salim <hadi@cyberus.ca>

Applied, thanks.
