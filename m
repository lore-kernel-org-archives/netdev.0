From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: e1000: add WoL fix for 2.6.17rc
Date: Fri, 26 May 2006 21:32:57 -0400
Message-ID: <4477AC49.3050007@pobox.com>
References: <44761DB2.8050806@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:17891 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S964886AbWE0Bc7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 May 2006 21:32:59 -0400
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <44761DB2.8050806@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> 
> Jeff,
> 
> Please queue the 'e1000: add shutdown handler back for WoL' for 
> 2.6.17rc's. Since this fix is already committed to 
> jgarzik/netdev-2.6#upstream, you can cherrypick it into #upstream-fixes:
> 
> $ git-cherry-pick c653e6351e371b33b29871e5eedf610ffb3be037

perfect, done, thanks.

	Jeff



