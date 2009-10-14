From: David Miller <davem@davemloft.net>
Subject: Re: PF_RING: Include in main line kernel?
Date: Wed, 14 Oct 2009 13:29:11 -0700 (PDT)
Message-ID: <20091014.132911.174712308.davem@davemloft.net>
References: <903D7FEC-34E8-4F70-ABC0-E56A3A5FBBE6@ntop.org>
	<20091014.131526.181354809.davem@davemloft.net>
	<A2EB721D-3AC9-4815-ADCC-EC0B311C5AE7@ntop.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bcook@bpointsys.com, brad.doctor@gmail.com, netdev@vger.kernel.org
To: deri@ntop.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49621
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754112AbZJNU3O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2009 16:29:14 -0400
In-Reply-To: <A2EB721D-3AC9-4815-ADCC-EC0B311C5AE7@ntop.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Luca Deri <deri@ntop.org>
Date: Wed, 14 Oct 2009 22:26:25 +0200

> I agree that some PF_RING features could be merged into
> PF_PACKET. However PF_RING is not just about improving packet capture
> but it implements facilities that can be used by many monitoring
> applications including, packet balancing, reflection, layer-7 packet
> filtering, pf_ring socket clustering just to name a few. You can read
> about PF_RING feature into this tutorial:
> http://luca.ntop.org/IM2009_Tutorial.pdf

I've already researched several times what PF_RING does and
is capable of doing, and my position still stands that none of
it can't be added to existing facilities.

It's been an out of tree hack for years, and if it stays as
a seperate facility it's likely to stay that way.
