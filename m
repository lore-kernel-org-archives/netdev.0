From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][NET_SCHED] Make HTB scheduler work with TSO.
Date: Tue, 10 Jul 2007 22:43:26 -0700 (PDT)
Message-ID: <20070710.224326.78734799.davem@davemloft.net>
References: <Pine.LNX.4.63.0706121647280.4120@ranjit.corp.google.com>
	<20070709.151522.52166816.davem@davemloft.net>
	<166fe7950707101502w65447adcm3f284df9494440ed@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ranjitm@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44386
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754523AbXGKFnE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 01:43:04 -0400
In-Reply-To: <166fe7950707101502w65447adcm3f284df9494440ed@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Ranjit Manomohan" <ranjitm@google.com>
Date: Tue, 10 Jul 2007 15:02:16 -0700

> On 7/9/07, David Miller <davem@davemloft.net> wrote:
> > From: Ranjit Manomohan <ranjitm@google.com>
> > Date: Tue, 12 Jun 2007 16:53:21 -0700 (PDT)
> >
> > > Currently the HTB scheduler does not correctly account for TSO packets
> > > which causes large inaccuracies in the bandwidth control when using TSO.
> > > This patch allows the HTB scheduler to work with TSO enabled devices.
> > >
> > > Signed-off-by: Ranjit Manomohan <ranjitm@google.com>
> >
> > Your patch has much white-space damage and therefore won't apply,
> > please fix this up and resubmit, thanks.
> >
> 
> patch based on net-2.6.23 attached.

Patch applied, thank you.
