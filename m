From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: [Bonding-devel] quick help with bonding?
Date: Thu, 29 Mar 2007 20:49:55 -0600
Message-ID: <460C7AD3.4060305@nortel.com>
References: <460BE5F0.7070606@nortel.com> <20070329181617.GA25770@gospo.rdu.redhat.com> <460C38EF.1080509@nortel.com> <4074.1175207458@death> <460C4EFE.6030505@nortel.com> <20070330003630.GA18319@gospo.rdu.redhat.com> <460C658C.7090803@nortel.com> <460C672F.404@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net
To: "Chris Friesen" <cfriesen@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zrtps0kn.nortel.com ([47.140.192.55]:44292 "EHLO
	zrtps0kn.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945924AbXC3CuG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2007 22:50:06 -0400
In-Reply-To: <460C672F.404@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Friesen wrote:

> No joy on the 2.6.14 backport, so I guess I'll try the RHEL4 route.

Bonding driver from 2.6.9-42.0.8.EL doesn't help at all, at least with 
the module parms I was using before.

Switching to miimon doesn't help either.

Chris
