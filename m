From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH resend] Renesas Ethernet AVB driver
Date: Tue, 31 Mar 2015 20:40:34 +0300
Message-ID: <551ADC12.5050603@cogentembedded.com>
References: <20150328082853.GA4255@localhost.localdomain>	<5519D380.6070200@cogentembedded.com>	<20150331064349.GB4605@localhost.localdomain> <20150331.113832.2042398685489897677.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, devicetree@vger.kernel.org,
	galak@codeaurora.org, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org, mitsuhiro.kimura.kc@renesas.com,
	masaru.nagai.vx@renesas.com
To: David Miller <davem@davemloft.net>, richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:36420 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752975AbbCaRki (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 13:40:38 -0400
Received: by lbbug6 with SMTP id ug6so18082049lbb.3
        for <netdev@vger.kernel.org>; Tue, 31 Mar 2015 10:40:37 -0700 (PDT)
In-Reply-To: <20150331.113832.2042398685489897677.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03/31/2015 06:38 PM, David Miller wrote:

>>>> We also need SOB from Mitsuhiro and Masaru.

>>>     Hmm, it's the first time I encounter such requirement.

>> I think this is normal policy.  I have seen it more than once on lkml.
>> The reason for the author's SOB is to make sure that he or she is
>> really authorized (like from the employer) to contribute the driver.

    We (Cogent Embedded) are authorized to do this, isn't this enough?

>> [adding davem on CC]

>> Dave, is that correct?

> I refuse to apply any patch without an appropriate signoff.

    But what do you mean by "appropriate signoff"? I have provided mine but 
Richard insists there should be sign-offs from the primary driver authors -- 
it's the first time I'm encountering such a requirement.

WBR, Sergei
