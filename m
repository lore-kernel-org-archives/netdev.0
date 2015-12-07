From: Phil Reid <preid@electromag.com.au>
Subject: Re: [PATCH v2 4/5] stmmac: Add ptp debugfs entry.
Date: Mon, 7 Dec 2015 21:37:52 +0800
Message-ID: <56658BB0.10700@electromag.com.au>
References: <1449452324-53858-1-git-send-email-preid@electromag.com.au>
 <1449452324-53858-6-git-send-email-preid@electromag.com.au>
 <2080516.uAzdPnupR8@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	peppe.cavallaro@st.com, davem@davemloft.net,
	devicetree@vger.kernel.org, netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from anchovy2.45ru.net.au ([203.30.46.146]:58927 "EHLO
	anchovy.45ru.net.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752938AbbLGNh7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 08:37:59 -0500
In-Reply-To: <2080516.uAzdPnupR8@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/12/2015 5:03 PM, Arnd Bergmann wrote:
> On Monday 07 December 2015 09:38:43 Phil Reid wrote:
>> This adds a debugfs entry to view the current status of the ptp
>> registers.
>>
>> Signed-off-by: Phil Reid <preid@electromag.com.au>
>>
>
> Your description should explain what this is good for. Why do you
> need to look at this through debugfs?
>

Happy to drop this one. I found it helpful when debugging the ptp
behaviour. Allowing quick access to monitor the register updates
by the ptp driver. Is there an alternative method that is preferred?

-- 
Regards
Phil Reid
