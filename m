From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: make bridge-nf-call-*tables default
 configurable
Date: Wed, 01 Jul 2009 09:02:02 -0700 (PDT)
Message-ID: <20090701.090202.247626454.davem@davemloft.net>
References: <1246379267.3749.42.camel@blaa>
	<20090630.201630.134200035.davem@davemloft.net>
	<1246445158.598.30.camel@blaa>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: markmc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33068
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752891AbZGAQB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2009 12:01:56 -0400
In-Reply-To: <1246445158.598.30.camel@blaa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark McLoughlin <markmc@redhat.com>
Date: Wed, 01 Jul 2009 11:45:58 +0100

> Weighing up the impact on the small number of people who use it versus
> the ongoing impact on everyone else, I think it's best to make the
> change.

Consider the posibility that the people using it aren't saying
anything because things just-work for them right now.

If you change this default, I guarentee we will hear from them.

"everyone else" is making noise only because the default isn't
what they want.  There is no other reason.
