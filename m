From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: make bridge-nf-call-*tables default
 configurable
Date: Wed, 01 Jul 2009 09:02:50 -0700 (PDT)
Message-ID: <20090701.090250.52376308.davem@davemloft.net>
References: <20090630.201630.134200035.davem@davemloft.net>
	<1246445158.598.30.camel@blaa>
	<4A4B3F9A.9060105@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: markmc@redhat.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33073
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752553AbZGAQCo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2009 12:02:44 -0400
In-Reply-To: <4A4B3F9A.9060105@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 01 Jul 2009 12:51:06 +0200

> I agree, this has already caused an endless amount of problems for
> users due to the unexpected behaviour and, in some cases, bugs.
> 
> Dave's point is certainly valid as well, until we change the defaults,
> distributions can use sysctl.conf. But I think we should move towards
> changing the defaults.

You must do this via something like your suggestion, the
feature-removal-schedule.txt thing.
