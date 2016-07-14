From: Davide Caratti <dcaratti@redhat.com>
Subject: Re: [iproute PATCH v2] ip-macsec.8: fix typo in 'examples' section
Date: Thu, 14 Jul 2016 18:26:22 +0200
Message-ID: <1468513582.20109.23.camel@redhat.com>
References: <49c1e540558e6b6ea422872e8bd4e8501e07e25a.1468310945.git.dcaratti@redhat.com>
	 <77dd47e67a8b89ccbe6e05c608ae9b9f5ce376b4.1468334712.git.dcaratti@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42017 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751160AbcGNQ0Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jul 2016 12:26:25 -0400
In-Reply-To: <77dd47e67a8b89ccbe6e05c608ae9b9f5ce376b4.1468334712.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-07-12 at 17:28 +0200, Davide Caratti wrote:
> fix wrong 'device' keyword in 'ip link add device eth0'
> 
> changes since v1:
> while at it, add missing description of 'validate' keyword and remove
> spurious bracket near 'encrypt' keyword. Also, wrong 'es' and 'encoding'
> keywords in MACsec section of ip-link.8 have been fixed.
> 
> Signed-off-by: Davide Caratti <dcaratti@redhat.com>

please drop this patch: I see that some other changes in this area are needed,
so I'm going to repost this - together with the rest of the work - as a series,
in order to avoid overhead.

thank you in advance,
regards,
