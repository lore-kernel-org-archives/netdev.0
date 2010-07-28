From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: br_forward.c - rcu dereference warning
Date: Wed, 28 Jul 2010 08:48:41 +0200
Message-ID: <1280299721.3832.0.camel@jlt3.sipsolutions.net>
References: <1280227553.3755.2.camel@jlt3.sipsolutions.net>
	 <20100727123859.GF3766@linux.vnet.ibm.com>
	 <20100727112630.5a5ce84b@nehalam>
	 <1280261679.3755.6.camel@jlt3.sipsolutions.net>
	 <20100727134223.5bb0be30@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:50438 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729Ab0G1Gsr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jul 2010 02:48:47 -0400
In-Reply-To: <20100727134223.5bb0be30@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-07-27 at 13:42 -0700, Stephen Hemminger wrote:

> > Did you want me to test the patch?
> 
> Yes please, I can make sure it works, but not that it gets rid
> of your error

Testing now, but it didn't quite apply cleanly on 2.6.35-rc.

johannes

