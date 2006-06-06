From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 1/2] e1000: fix netpoll with NAPI
Date: Tue, 06 Jun 2006 10:34:26 -0700
Message-ID: <4485BCA2.5070904@intel.com>
References: <20060605230917.12584.55755.stgit@gitlost.site>	<20060605231125.12584.17039.stgit@gitlost.site>	<20060606135217.GA21969@hmsreliant.homelinux.net>	<1149611965.13635.19.camel@strongmad>	<20060606170513.GB21969@hmsreliant.homelinux.net>	<4485B8EC.4090603@intel.com> <x494pyyw5sr.fsf@segfault.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Garzik, Jeff" <jgarzik@pobox.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>, mpm@selenic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr17.intel.com ([134.134.136.16]:9142 "EHLO
	orsfmr002.jf.intel.com") by vger.kernel.org with ESMTP
	id S1750720AbWFFRfZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jun 2006 13:35:25 -0400
To: Jeff Moyer <jmoyer@redhat.com>
In-Reply-To: <x494pyyw5sr.fsf@segfault.boston.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Moyer wrote:
> ==> Regarding Re: [PATCH 1/2] e1000: fix netpoll with NAPI; Auke Kok <auke-jan.h.kok@intel.com> adds:
> 
> auke-jan.h.kok> Neil Horman wrote:
>>> On Tue, Jun 06, 2006 at 09:39:25AM -0700, Mitch Williams wrote:
>>>> On Tue, 2006-06-06 at 09:52 -0400, Neil Horman wrote:
> 
> 
> auke-jan.h.kok> [snip]
> 
> 
>>>> However, just for the sake of correctness (and paranoia), I'll whip up
>>>> another patch that does this check.
>>>>
>>> Thanks for the quick feedback!
>>> Regards
>>> Neil
>>>
>>>> Jeff, please do not commit this patch.
> 
> auke-jan.h.kok> Jeff,
> 
> auke-jan.h.kok> I've popped the patch off from our gitserver, so you can pull the two
> auke-jan.h.kok> outstanding patches while we revamp this one.
> 
> Would you please send patches to this list?  I'd certainly like to review
> them.  I don't think the problem needs solving in the e1000 driver.  I
> think it is an issue that should be handled properly by netpoll.

???

that message was directed to Jeff Garzik, perhaps that was too confusing.


They were sent here in the first place:

http://marc.theaimsgroup.com/?l=linux-netdev&m=114954878711789&w=2


Cheers,

Auke

