From: David Miller <davem@davemloft.net>
Subject: Re: netns XFRM preview
Date: Fri, 21 Nov 2008 21:49:53 -0800 (PST)
Message-ID: <20081121.214953.248231348.davem@davemloft.net>
References: <20081121152106.GA29944@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containters@lists.osdl.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39081
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756335AbYKVFty (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Nov 2008 00:49:54 -0500
In-Reply-To: <20081121152106.GA29944@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Fri, 21 Nov 2008 18:21:06 +0300

> I'm several days away from posting netns xfrm patchset which will make IPsec
> to work inside netns container. There are still some tricky places which
> aren't ready, but, anyway, here is big picture, so hopefully big misdesigns
> can be found earlier:

It looks fine as far as I can tell, especially for a first
pass.
