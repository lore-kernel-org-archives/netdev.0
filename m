From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 10/21] e1000: force register write flushes to circumvent
 broken platforms
Date: Tue, 27 Jun 2006 11:41:40 -0400
Message-ID: <44A151B4.6040200@pobox.com>
References: <20060622051815.25497.89192.stgit@gitlost.site> <20060622052027.25497.51513.stgit@gitlost.site> <44A08E33.3020501@pobox.com> <44A14283.50301@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:11911 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1161113AbWF0Plo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2006 11:41:44 -0400
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <44A14283.50301@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> If there is an in-kernel fix for this that would make these flushes 
> obsolete I would certainly prefer it too, unfortunately we can't fix 
> already released kernels and our driver still needs to work there too, 
> so that's why I queued it. It can be dropped from this series if that's 
> preferred.

Yes, definitely drop it from the series...

	Jeff


