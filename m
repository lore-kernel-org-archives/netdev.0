From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 1/2] e1000: fix netpoll with NAPI
Date: Tue, 06 Jun 2006 10:18:36 -0700
Message-ID: <4485B8EC.4090603@intel.com>
References: <20060605230917.12584.55755.stgit@gitlost.site> <20060605231125.12584.17039.stgit@gitlost.site> <20060606135217.GA21969@hmsreliant.homelinux.net> <1149611965.13635.19.camel@strongmad> <20060606170513.GB21969@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>, jmoyer@redhat.com,
	mpm@selenic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr18.intel.com ([134.134.136.17]:19147 "EHLO
	orsfmr003.jf.intel.com") by vger.kernel.org with ESMTP
	id S1750728AbWFFRUz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jun 2006 13:20:55 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060606170513.GB21969@hmsreliant.homelinux.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Neil Horman wrote:
> On Tue, Jun 06, 2006 at 09:39:25AM -0700, Mitch Williams wrote:
>> On Tue, 2006-06-06 at 09:52 -0400, Neil Horman wrote:


[snip]


>> However, just for the sake of correctness (and paranoia), I'll whip up
>> another patch that does this check.
>>
> Thanks for the quick feedback!
> 
> Regards
> Neil
> 
>> Jeff, please do not commit this patch.

Jeff,

I've popped the patch off from our gitserver, so you can pull the two 
outstanding patches while we revamp this one.

Auke

