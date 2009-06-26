From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vxge: fix GRO receive with INTA interrupts
Date: Fri, 26 Jun 2009 00:47:44 -0700 (PDT)
Message-ID: <20090626.004744.100591404.davem@davemloft.net>
References: <20090625183134.40e8fd7a@leela>
	<78C9135A3D2ECE4B8162EBDCE82CAD77056E4779@nekter>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mschmidt@redhat.com, netdev@vger.kernel.org
To: Ramkrishna.Vepa@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39213
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752798AbZFZHrj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 03:47:39 -0400
In-Reply-To: <78C9135A3D2ECE4B8162EBDCE82CAD77056E4779@nekter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Date: Thu, 25 Jun 2009 17:18:19 -0400

> Thanks. We are in the midst of submitting a few bug fixes and will add
> this fix to the list. We fixed it without assuming that only 1 vpath
> will be enabled with INTA. It's been hard coded to 1 with INTA, for
> performance reasons, but when I get some time, I'd like to optimize the
> completion handling to over come this issue.


Since you say you'll integrate into your fix pile I'll wait for
that.
