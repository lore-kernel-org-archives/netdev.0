From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v4 1/5] net: cpsw: enhance pinctrl support
Date: Thu, 13 Jun 2013 02:54:44 -0700 (PDT)
Message-ID: <20130613.025444.626549509946164895.davem@davemloft.net>
References: <20130607.004234.2007576325541054686.davem@davemloft.net>
	<51B1F2EB.80109@ti.com>
	<CACRpkdbKWRyBxUF1w82C8WUAvXM5hsUc6N-C+CcwXr8eCyviWQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, broonie@kernel.org, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org, gururaja.hebbar@ti.com,
	benoit.cousson@linaro.org, linux-omap@vger.kernel.org
To: linus.walleij@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38667 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758548Ab3FMJyp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 05:54:45 -0400
In-Reply-To: <CACRpkdbKWRyBxUF1w82C8WUAvXM5hsUc6N-C+CcwXr8eCyviWQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Walleij <linus.walleij@linaro.org>
Date: Mon, 10 Jun 2013 17:48:16 +0200

> On Fri, Jun 7, 2013 at 4:49 PM, Mugunthan V N <mugunthanvnm@ti.com> wrote:
> 
>>> If you want to merge the direct networking parts of this series into
>>> another tree, I'm fine with that:
>>>
>>> Acked-by: David S. Miller <davem@davemloft.net>
>>
>> David
>>
>> Can you the below patch series as i have adopted pinctrl PM api in another
>> series,
>> this patch has direct usage of pinctrl_select_state apis
>> http://marc.info/?l=linux-netdev&m=137054250018667&w=2
>>
>> Linus Walleij
>>
>> Please drop this patch series and take my other [atch set mentioned above
>> with David's Ack.
> 
> Sure I didn't see David ACK the new versions explicitly but
> since they're even less intrusive I'll apply them assuming
> his ACK on these versions too...

Just in case it isn't clear:

Acked-by: David S. Miller <davem@davemloft.net>
