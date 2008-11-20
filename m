From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: macb phy address bug?
Date: Thu, 20 Nov 2008 16:59:26 +0100
Message-ID: <4925895E.6080905@st.com>
References: <20081116.015050.238612963.davem@davemloft.net>	<492281C9.6060006@st.com> <20081120.010434.259572554.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: giulio.benetti@micronovasrl.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:53085 "EHLO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751909AbYKTQCx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 11:02:53 -0500
In-Reply-To: <20081120.010434.259572554.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've just sent a new patch (named " phy: fix phy_id detection also for 
broken hardware.").

Peppe

David Miller wrote:
> From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
> Date: Tue, 18 Nov 2008 09:50:17 +0100
>
>   
>> Fix phy_id detection also for broken hardware.
>>
>> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
>>
>> --- phy_device.c.orig	2008-11-18 09:25:06.929041000 +0100
>> +++ phy_device.c	2008-11-18 09:27:15.876041000 +0100
>>     
>
> Please -p1 base your patches with the top-level kernel tree,
> as described in linux/Documentation/SubmittingPatches
>
> Please make a full resubmission, with full changelog and
> signoffs, when you correct this.  Don't just resend the
> fixed patch.
>
> Thank you.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>   

