From: Michal Schmidt <xschmi00@stud.feec.vutbr.cz>
Subject: Re: [PATCH] e1000 stop raw interrupts disabled nag from RT
Date: Thu, 01 Mar 2007 18:34:59 +0100
Message-ID: <45E70EC3.40809@stud.feec.vutbr.cz>
References: <45E64080.4070004@mvista.com> <45E645F4.2090403@intel.com> <45E65DCF.8050903@mvista.com> <45E70586.60201@intel.com> <45E70959.4070209@stud.feec.vutbr.cz> <45E70D72.5020803@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Mark Huth <mhuth@mvista.com>, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Ingo Molnar <mingo@elte.hu>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:39435 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965449AbXCARh0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Mar 2007 12:37:26 -0500
In-Reply-To: <45E70D72.5020803@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> uhh, sure... while we are at it then, are there any more patches like this? 
> perhaps for e100? ixgb?

A quick grep through the current RT patch shows there are no other
changes to e100, e1000, ixgb.

Michal

