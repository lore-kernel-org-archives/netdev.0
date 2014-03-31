From: zhangfei <zhangfei.gao@linaro.org>
Subject: Re: [PATCH 2/3] net: hisilicon: new hip04 MDIO driver
Date: Mon, 31 Mar 2014 10:45:29 +0800
Message-ID: <5338D6C9.4060404@linaro.org>
References: <1396020960-6170-1-git-send-email-zhangfei.gao@linaro.org>	<1396020960-6170-3-git-send-email-zhangfei.gao@linaro.org> <20140330.172313.2128642789143277676.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux@arm.linux.org.uk, arnd@arndb.de, f.fainelli@gmail.com,
	sergei.shtylyov@cogentembedded.com, mark.rutland@arm.com,
	David.Laight@ACULAB.COM, eric.dumazet@gmail.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:58567 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752657AbaCaCpj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Mar 2014 22:45:39 -0400
Received: by mail-pb0-f44.google.com with SMTP id rp16so7529692pbb.31
        for <netdev@vger.kernel.org>; Sun, 30 Mar 2014 19:45:38 -0700 (PDT)
In-Reply-To: <20140330.172313.2128642789143277676.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 03/31/2014 05:23 AM, David Miller wrote:
> From: Zhangfei Gao <zhangfei.gao@linaro.org>
> Date: Fri, 28 Mar 2014 23:35:59 +0800
>
>> +	  Note that the answer to this question doesn't directly affect the
>> +	  kernel: saying N will just cause the configurator to skip all
>> +	  the questions about MOXA ART devices. If you say Y, you will be asked
>> +	  for your specific card in the following questions.
>
> Please don't just cut and paste things from unrelated Kconfig entries.
>
> This Kconfig option has nothing to do with MOXA ART devices.
>
My bad, will update in new version.
