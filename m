From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH resend] Renesas Ethernet AVB driver
Date: Tue, 31 Mar 2015 08:43:49 +0200
Message-ID: <20150331064349.GB4605@localhost.localdomain>
References: <2926619.fiYHPz1IBk@wasted.cogentembedded.com>
 <20150328082853.GA4255@localhost.localdomain>
 <5519D380.6070200@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, devicetree@vger.kernel.org,
	galak@codeaurora.org, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	masaru.nagai.vx@renesas.com, David Miller <davem@davemloft.net>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:33241 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752568AbbCaGnz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 02:43:55 -0400
Content-Disposition: inline
In-Reply-To: <5519D380.6070200@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 31, 2015 at 01:51:44AM +0300, Sergei Shtylyov wrote:
> On 03/28/2015 11:28 AM, Richard Cochran wrote:
> >We also need SOB from Mitsuhiro and Masaru.
> 
>    Hmm, it's the first time I encounter such requirement.

I think this is normal policy.  I have seen it more than once on lkml.
The reason for the author's SOB is to make sure that he or she is
really authorized (like from the employer) to contribute the driver.

[adding davem on CC]

Dave, is that correct?

Thanks,
Richard
