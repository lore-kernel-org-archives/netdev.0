From: David Miller <davem@davemloft.net>
Subject: Re: I can tell no FIB
Date: Thu, 05 Mar 2015 22:20:28 -0500 (EST)
Message-ID: <20150305.222028.124409116923713198.davem@davemloft.net>
References: <54F8D249.4080404@gmail.com>
	<CAE4R7bB1Z_gBbaUQLXz2FRS3SSVZp__n-PNnGfX16-Apscf=YA@mail.gmail.com>
	<54F8F2DB.5070901@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, alexander.h.duyck@redhat.com,
	netdev@vger.kernel.org
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38697 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753806AbbCFDUb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 22:20:31 -0500
In-Reply-To: <54F8F2DB.5070901@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Thu, 05 Mar 2015 16:20:43 -0800

> Well the last batch of patches are out there, but there isn't any rush
> on them.  If need be Dave can just leave them in review until we get the
> thumbs up or down on the v4 changes since I think you and I are probably
> the only two patching that region for now.  I suspect the changes
> shouldn't be as bad as the past patches have been since most of it is
> just reworking structures and updating the resize code.

Scott just tell me what you want me to do, I can hold off on
Alex's current series while you put v4 of your stuff together.
