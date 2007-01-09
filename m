From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] INET: style updates for the inet_sock->is_icsk
 assignment fix
Date: Tue, 09 Jan 2007 14:37:23 -0800 (PST)
Message-ID: <20070109.143723.89062707.davem@davemloft.net>
References: <20070109175144.787024589@flek.zko.hp.com>
	<39e6f6c70701091045v2b5b1eeck350c71f5a4c91db1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.moore@hp.com, netdev@vger.kernel.org, jarkao2@o2.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59694
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932368AbXAIWhY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jan 2007 17:37:24 -0500
To: arnaldo.melo@gmail.com
In-Reply-To: <39e6f6c70701091045v2b5b1eeck350c71f5a4c91db1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Tue, 9 Jan 2007 16:45:12 -0200

> On 1/9/07, Paul Moore <paul.moore@hp.com> wrote:
> > A quick patch to change the inet_sock->is_icsk assignment to better fit with
> > existing kernel coding style.
> >
> > Signed-off-by: Paul Moore <paul.moore@hp.com>
> > Cc: Jarek Poplawski <jarkao2@o2.pl>
> > Cc: Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com>
> 
> Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>

Ok, the style police win :)
