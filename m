From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH v3 0/4] FEC - fast ethernet controller for mpc52xx
Date: Thu, 18 Oct 2007 15:14:35 -0400
Message-ID: <4717B09B.3060800@pobox.com>
References: <20071014075511.GC3000@nd47.coderock.org>	 <4713BA1C.2050604@pobox.com> <fa686aa40710180715u23d81adfy83ff65837725fb80@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Domen Puncer <domen.puncer@telargo.com>, galak@kernel.crashing.org,
	linuxppc-dev@ozlabs.org, tnt@246tnt.com, netdev@vger.kernel.org
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58112 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758866AbXJRTOn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Oct 2007 15:14:43 -0400
In-Reply-To: <fa686aa40710180715u23d81adfy83ff65837725fb80@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Grant Likely wrote:
> On 10/15/07, Jeff Garzik <jgarzik@pobox.com> wrote:
>> Domen Puncer wrote:
>>> Hello!
>>>
>>> If there are no objections, I would like to get this merged
>>> when bestcomm goes in (any time now?).
>>>
>>> It's split into four parts:
>>> 1 - device tree
>>> 2 - small bestcomm change
>>> 3 - the actual driver
>>> 4 - phy part of the driver
>> patches #3 and #4 need to be combined together.
>>
>> Are the arch people OK with patches #1 and #2?
> 
> Jeff,
> 
> The bestcomm patches and patch 1 & 2 from this series are now in
> Linus' tree.  That clears the way for the FEC driver when Domen
> reposts it.  (In other words; there is nothing left in arch land
> blocking this driver)
> 

except a resend combining patches 3 and 4 as requested :)


