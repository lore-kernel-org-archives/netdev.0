From: Li Wei <lw@cn.fujitsu.com>
Subject: Re: [PATCH] tc-tbf.8: Add parameter range to man page.
Date: Tue, 21 Aug 2012 08:48:25 +0800
Message-ID: <5032DAD9.4050003@cn.fujitsu.com>
References: <1344306632-15288-1-git-send-email-lw@cn.fujitsu.com> <20120813083015.27b66cd7@nehalam.linuxnetplumber.net> <5031DADC.6060509@cn.fujitsu.com> <20120820105803.2ce45a2a@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:32306 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753467Ab2HUAtZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Aug 2012 20:49:25 -0400
In-Reply-To: <20120820105803.2ce45a2a@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/21/2012 01:58 AM, Stephen Hemminger wrote:
> 
>>
>> Not very clear with "the generic documentation about qdisc parameters
>> which already exists on 'tc-qdisc' man page", is there a separate man page
>> that describe qdisc parameters?
>>
>> I'm reading the iproute2 and kernel code which related to TC and record the
>> value range for each parameter, I think that would be helpful for somebody
>> else.
>>
> 
> Rather than putting range on each parameter on every sub-page of tc man
> page. Why not put something in tc.8 under UNITS.
> 
> The following implies everything is floating-point which it isn't:
> 
> UNITS
>        All parameters accept a floating point number, possibly followed  by  a
>        unit.
> 
> I would like this section broken down to cover all the generic types
>   PARAMETERS
>      RATES
>      TIMES
>      SIZES
>      VALUES
> 
> Also needs to explain IEC units here.
> 
> 
>

Thanks Stephen, I got it and will try to work it out.
 
