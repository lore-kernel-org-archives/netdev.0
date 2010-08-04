From: Igor Grinberg <grinberg@compulab.co.il>
Subject: Re: [PATCH 2/8] davinci: add mdio platform devices
Date: Wed, 04 Aug 2010 09:58:26 +0300
Message-ID: <4C590F92.1040003@compulab.co.il>
References: <1280842313-3743-1-git-send-email-cyril@ti.com> <1280842313-3743-3-git-send-email-cyril@ti.com> <4C58227A.4080502@compulab.co.il> <4C582879.7060708@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davinci-linux-open-source@linux.davincidsp.com"
	<davinci-linux-open-source@linux.davincidsp.com>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"Nori, Sekhar" <nsekhar@ti.com>,
	"Govindarajan, Sriramakrishnan" <srk@ti.com>
To: cyril@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from compulab.co.il ([67.18.134.219]:39837 "EHLO compulab.co.il"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758259Ab0HDG6e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Aug 2010 02:58:34 -0400
In-Reply-To: <4C582879.7060708@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/03/10 17:32, Cyril Chemparathy wrote:
> Hi Igor,
>
>   
>> Shouldn't arch/arm/mach-omap2/board-am3517evm.c be on your list?
>> I think it should, or else it will be broken by:
>> [PATCH 5/8] netdev: cleanup unused davinci mdio emac code
>>     
> Correct.  As stated in the series summary:
>
>   
>> Additional omap tree patches will be required for am35xx as well
>> (not included here).
>>     

Sorry for missing that,
my laziness and long cover letter made me miss it :)
Do you plan on bringing those patches?
Wouldn't it be better for those patches to be included in the series?
Because, merging code that breaks other platform(s) is not so nice...

> Regards
> Cyril.
>
>   

-- 
Regards,
Igor.

