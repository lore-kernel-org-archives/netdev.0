From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 3/4] Make Intel e1000 driver legacy I/O port free
Date: Wed, 07 Jun 2006 07:40:50 -0700
Message-ID: <4486E572.4040201@intel.com>
References: <447E91CE.7010705@intel.com> <20060601024611.A32490@unix-os.sc.intel.com> <20060601171559.GA16288@colo.lackof.org> <20060601113625.A4043@unix-os.sc.intel.com> <447FA920.9060509@jp.fujitsu.com> <4484263C.1030508@jp.fujitsu.com> <20060606075812.GB19619@kroah.com> <448643B9.2080805@jp.fujitsu.com> <448644A2.7000208@jp.fujitsu.com> <44865FD8.4060801@foo-projects.org> <448682B6.5010302@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Auke Kok <sofar@foo-projects.org>, Greg KH <greg@kroah.com>,
	akpm@osdl.org, Rajesh Shah <rajesh.shah@intel.com>,
	Grant Grundler <grundler@parisc-linux.org>,
	"bibo,mao" <bibo.mao@intel.com>, linux-kernel@vger.kernel.org,
	linux-pci@atrey.karlin.mff.cuni.cz, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr18.intel.com ([134.134.136.17]:12690 "EHLO
	orsfmr003.jf.intel.com") by vger.kernel.org with ESMTP
	id S932240AbWFGOmS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jun 2006 10:42:18 -0400
To: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
In-Reply-To: <448682B6.5010302@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kenji Kaneshige wrote:
> Auke Kok wrote:
>> Kenji Kaneshige wrote:
>>
>>> This patch makes Intel e1000 driver legacy I/O port free.
>>>
>>> Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
>>
>> (adding netdev and the other e1000 maintainers to cc:)
>>
>> without sending this to any of the listed e1000 maintainers???? *and* 
>> not even including netdev???
>>
> 
> I'm sorry about that.

I also didn't see that you were sending this to Greg-KH. I think I got thrown 
off by that as I wasn't following lkml until yesterday in the first place. 
I'll toss the patches around over here and see what comes up.

Cheers,

Auke

