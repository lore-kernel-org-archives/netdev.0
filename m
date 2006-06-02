From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [FIX] e1000: fix irq sharing when running ethtool test
Date: Fri, 02 Jun 2006 15:32:49 -0700
Message-ID: <4480BC91.1060402@intel.com>
References: <4480B983.50702@intel.com> <20060602222229.GA24528@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr18.intel.com ([134.134.136.17]:54722 "EHLO
	orsfmr003.jf.intel.com") by vger.kernel.org with ESMTP
	id S932581AbWFBWfE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Jun 2006 18:35:04 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <20060602222229.GA24528@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> On Fri, Jun 02, 2006 at 03:19:47PM -0700, Auke Kok wrote:
>> Because upstream and upstream-fixes have a whitespace conflict in them, 
>> I've prepared two separate git branches to pull from so that a subsequent 
>> pull or merge from upstream-fixes into upstream doesn't resolve into a 
>> conflict:
> 
> That won't work, because it creates duplicate changesets in the history.
> 
> I'll pull the upstream-fixes version, and then merge into #upstream.

thanks, I wish I had thought of that first!

Auke
