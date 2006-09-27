From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [GIT PATCH] e100, e1000, ixgb updates for #upstream
Date: Wed, 27 Sep 2006 18:02:25 -0400
Message-ID: <451AF4F1.40303@pobox.com>
References: <451ADF96.7030407@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:14536 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1031008AbWI0WC2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 18:02:28 -0400
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <451ADF96.7030407@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> 
> Hi,
> 
> Here are updated updates targeted to branch #upstream-fixes from 
> netdev-2.6, including
> fixes to e100, e1000 and ixgb.
> 
> Changes from last weeks submission:
> 1) removed taint flag setting when eeprom csum fails (e100)
> 2) added CONFIG_PM wrappers around .suspend mthod (e1000)
> 3) added comments and (1 << n) for hardware bit spanking function (e1000)
> 4) keep flow control enum (e1000)
> 5) clean up ethtool stats as much as possible to use real HW counters 
> (e1000)
> 6) add patch from linas Vepstas (e1000, PCI_D3 etc state symbols)
> 7) add patch from Vasily Averin (e1000, memleak in e1000_set_ringparam)
> 
> 
> Please pull from:
> 
> git pull git://lost.foo-projects.org/~ahkok/git/netdev-2.6 upstream

pulled


