From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] act_mirred: combine duplicate code
Date: Wed, 30 Jun 2010 12:13:08 -0700 (PDT)
Message-ID: <20100630.121308.215555952.davem@davemloft.net>
References: <1277888098-27632-1-git-send-email-xiaosuo@gmail.com>
	<1277893442.3509.16.camel@bigi>
	<1277894942.3509.25.camel@bigi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40683
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756492Ab0F3TMz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 15:12:55 -0400
In-Reply-To: <1277894942.3509.25.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jamal <hadi@cyberus.ca>
Date: Wed, 30 Jun 2010 06:49:02 -0400

> On Wed, 2010-06-30 at 06:24 -0400, jamal wrote:
> 
>> m->tcf_qstats.drops.
> 
> Sorry - this nagged me - we are already incrementing overlimits - we
> should increment drops. Scratch that too. I am going to say your patch
> as is:
> signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

Applied.

Jamal, please capitalize "Signed-off-by" in the future, thanks.
