From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Wed, 6 Jun 2007 19:36:34 -0400
Message-ID: <20070606233634.GD3304@havoc.gtf.org>
References: <20070606.160048.45742078.davem@davemloft.net> <D5C1322C3E673F459512FB59E0DDC32902FC6292@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, hadi@cyberus.ca
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:51104 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965021AbXFFXgg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jun 2007 19:36:36 -0400
Content-Disposition: inline
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32902FC6292@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 06, 2007 at 04:14:12PM -0700, Waskiewicz Jr, Peter P wrote:
> > While I am growing in support of your changes, there are two things:
> > 
> > 1) I want to study them more and hear more about what Patrick has to
> >    say about them when he returns from his trip on Sunday
> > 
> > 2) I don't want to open up a net-2.6.23 tree yet so that people
> >    concentrate on bug fixes and regressions, pick an open bug or
> >    regression report and help out if you want net-2.6.23 cut faster
> >    :-)
> 
> Where can I find such reports?

Michal Piotrowski's list is a good place to start, while not
network-specific, is turning into _the_ place to list regressions.

	Jeff



