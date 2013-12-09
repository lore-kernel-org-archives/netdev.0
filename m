From: Christophe Gouault <christophe.gouault@6wind.com>
Subject: Re: [PATCH RFC 0/9] vti4: prepare namespace and interfamily support.
Date: Mon, 09 Dec 2013 10:17:38 +0100
Message-ID: <52A58AB2.9010100@6wind.com>
References: <20131205120028.GW31491@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Saurabh Mohan <saurabh.mohan@vyatta.com>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:41585 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932191Ab3LIJRm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 04:17:42 -0500
Received: by mail-wg0-f48.google.com with SMTP id z12so3069064wgg.3
        for <netdev@vger.kernel.org>; Mon, 09 Dec 2013 01:17:41 -0800 (PST)
In-Reply-To: <20131205120028.GW31491@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Steffen,

On 12/05/2013 01:00 PM, Steffen Klassert wrote:
> This patchset prepares vti4 for proper namespace and interfamily support.
> It is based on the net tree because net-next is still too far behind the
> mainline.
[...]
>
> It has not much testing so far. I can setup the vti tunnels and ping through
> it. That's all I tried so test carefully ;-).

This series of patchs looks good and seems to address all identified 
limitations of the current vti implementation.

I'll try to run deeper tests this week. Thank you for working on 
improving vti.

Best Regards,
Christophe

> I'll start to care about the ipv6 side after I've got some feedback on this.
>
