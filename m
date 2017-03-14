From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH] net: stmmac: set default number of rx and tx queues in
 stmmac_pci
Date: Tue, 14 Mar 2017 09:53:17 +0000
Message-ID: <054b313f-4d6a-e417-4d9a-8aa3133daa67@synopsys.com>
References: <d8f9e892defdcaf7f7e5fe795f2072b16f7e6b87.1489399548.git.jpinto@synopsys.com>
 <20170313.121259.2282966988475158031.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <peppe.cavallaro@st.com>, <alexandre.torgue@st.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay2.synopsys.com ([198.182.60.111]:44991 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750796AbdCNJxX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 05:53:23 -0400
In-Reply-To: <20170313.121259.2282966988475158031.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Às 7:12 PM de 3/13/2017, David Miller escreveu:
> From: Joao Pinto <Joao.Pinto@synopsys.com>
> Date: Mon, 13 Mar 2017 10:07:07 +0000
> 
>> This patch configures default number of RX and TX queues when
>> using the pci glue driver.
>>
>> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
> 
> This is a net-next specific patch, you must the target tree properly in your
> Subject line or similar, for example:

You are right, sorry, I forgot to put the target tree!

> 
> 	[PATCH net-next] stmmac: set default ...
> 
> I'm taking care of this, and for the next patch too, but in the future you
> need to be clear what tree your changes are targetting.
> 
> Thanks.
> 

Thanks,
Joao
