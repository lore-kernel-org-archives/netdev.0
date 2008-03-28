From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] [LLC]: bogus llc packet length
Date: Fri, 28 Mar 2008 16:27:43 -0700 (PDT)
Message-ID: <20080328.162743.68552016.davem@davemloft.net>
References: <1206691175-10905-1-git-send-email-joonwpark81@gmail.com>
	<20080328131317.GQ14945@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joonwpark81@gmail.com, netdev@vger.kernel.org
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35533
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756124AbYC1X1s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 19:27:48 -0400
In-Reply-To: <20080328131317.GQ14945@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Fri, 28 Mar 2008 10:13:17 -0300

> Em Fri, Mar 28, 2008 at 04:59:35PM +0900, Joonwoo Park escreveu:
> > discard llc packet which has bogus packet length.
> > 
> > Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
> > Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
> 
> Dave, can you please apply this one?

Applied, thanks.
