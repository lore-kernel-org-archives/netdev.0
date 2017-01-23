From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH] net: stmicro: fix LS field mask in EEE configuration
Date: Mon, 23 Jan 2017 10:17:02 +0000
Message-ID: <be0b0899-77b1-702f-af01-f6694765df4e@synopsys.com>
References: <ed690f703a3c82193737f1a9813dff8b1ff403dd.1484927665.git.jpinto@synopsys.com>
 <20170122.164953.874236089744264438.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <rayagond@vayavyalabs.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay4.synopsys.com ([198.182.47.9]:36958 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750703AbdAWKRH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 05:17:07 -0500
In-Reply-To: <20170122.164953.874236089744264438.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Às 9:49 PM de 1/22/2017, David Miller escreveu:
> From: Joao Pinto <Joao.Pinto@synopsys.com>
> Date: Fri, 20 Jan 2017 16:00:26 +0000
> 
>> This patch fixes the LS mask when setting EEE timer.
>> LS field is 10 bits long and not 11 as currently.
>>
>> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
>> Reported-By: Rayagond Kokatanur <rayagond@vayavyalabs.com>
> 
> Please indicate the appropriate target tree of your patch in the
> subject line just like all other developers on this list do, don't
> make me guess.

Sorry, I will follow that rule also of course.

> 
> This time I figured out that this is meant for the net-next tree,
> but I will not guess next time, I will just reject your patch
> instead.
> 
> Thanks.
> 

Thanks.
Joao
