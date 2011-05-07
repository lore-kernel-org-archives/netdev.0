From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net/bonding: adjust codingstyle for bond_3ad files
Date: Sat, 07 May 2011 13:24:24 -0700
Message-ID: <1304799864.1738.10.camel@Joe-Laptop>
References: <20110507012717.GA15854@x61.tchesoft.com>
	 <1304733100.11874.33.camel@Joe-Laptop>
	 <20110507173141.GA4204@x61.tchesoft.com>
	 <1304791360.1738.6.camel@Joe-Laptop>
	 <BANLkTimKs39m_htMFEygR+3Bfu7Butc-zQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, shemminger@vyatta.com,
	netdev@vger.kernel.org, Nicolas Kaiser <nikai@nikai.net>,
	kernel-janitors@vger.kernel.org, aquini@linux.com
To: matt mooney <mfmooney@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1345 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752484Ab1EGUY0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 May 2011 16:24:26 -0400
In-Reply-To: <BANLkTimKs39m_htMFEygR+3Bfu7Butc-zQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2011-05-07 at 12:35 -0700, matt mooney wrote:
> On Sat, May 7, 2011 at 11:02 AM, Joe Perches <joe@perches.com> wrote:
> > I'd write this not using a retval variable at all as:
[]
> But isn't the preferred style to have a single exit point?

I don't think so.  It's not pascal.


