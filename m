From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: ti: cpdma: use desc_read in
 chan_process instead of raw read
Date: Mon, 05 Dec 2016 14:47:58 -0500 (EST)
Message-ID: <20161205.144758.174392232935805435.davem@davemloft.net>
References: <1480730715-16000-1-git-send-email-ivan.khoronzhuk@linaro.org>
        <ed16f5d1-8e5b-470f-1566-4129eef47ee1@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ivan.khoronzhuk@linaro.org, mugunthanvnm@ti.com,
        linux-omap@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: grygorii.strashko@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ed16f5d1-8e5b-470f-1566-4129eef47ee1@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Grygorii Strashko <grygorii.strashko@ti.com>
Date: Mon, 5 Dec 2016 12:47:16 -0600

> 
> 
> On 12/02/2016 08:05 PM, Ivan Khoronzhuk wrote:
>> There is desc_read() macros to read desc fields, so no need to
>> use __raw_readl();
>>
>> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
> 
> 
> I'm going to update it all at once as part of [1].
> 
> [1] https://lkml.org/lkml/2016/12/1/781

Ok.
