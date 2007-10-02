From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH][E1000E] some cleanups
Date: Tue, 02 Oct 2007 10:43:45 -0700
Message-ID: <47028351.7090509@intel.com>
References: <1191174077.6165.11.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:60857 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751817AbXJBRoo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2007 13:44:44 -0400
In-Reply-To: <1191174077.6165.11.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> Auke,
> 
> heres part of something i promised. 
> I couldnt do any packet testing on because 82571EB is disabled in the
> driver. I uncommented the code out in the table, but the best i could
> get was the module loading, some probing and some sysfs renaming
> failures (probably a debianism); the machine access is intermittent, so
> thats as far as i could go. In any case, you probably have a good reason
> for disabling that chip. So, heres the patch, the burden of testing now
> falls on you ;->


the description of this patch is rather misleading, and the title certainly too.
Can you resend this with a bit more elaborate explanation as to why the cb code is
relevant to use here? Not only do I need to understand this, but others might want
to as well later on ;)

Cheers,

Auke
