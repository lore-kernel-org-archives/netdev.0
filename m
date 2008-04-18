From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][netlabel] Don't risk NULL ptr deref in
 netlbl_unlabel_staticlist_gen() if ifindex not found
Date: Thu, 17 Apr 2008 23:23:11 -0700 (PDT)
Message-ID: <20080417.232311.256794268.davem@davemloft.net>
References: <alpine.LNX.1.00.0804162304220.9837@dragon.funnycrock.com>
	<200804161721.33749.paul.moore@hp.com>
	<9a8748490804161430w3a9a9ed8o4dcc80d260a14500@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.moore@hp.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jesper.juhl@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44218
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753140AbYDRGXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 02:23:12 -0400
In-Reply-To: <9a8748490804161430w3a9a9ed8o4dcc80d260a14500@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jesper Juhl" <jesper.juhl@gmail.com>
Date: Wed, 16 Apr 2008 23:30:10 +0200

> On 16/04/2008, Paul Moore <paul.moore@hp.com> wrote:
> >  Acked-by: Paul Moore <paul.moore@hp.com>
> >
> 
> David, will you merge this in the net tree ?

I've done that, thanks everyone.
