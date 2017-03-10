From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH v4 net-next 0/9] prepare mac operations for multiple
 queues
Date: Fri, 10 Mar 2017 18:00:17 +0000
Message-ID: <3beb07f5-3c1a-cfec-66a4-c92c02467541@synopsys.com>
References: <cover.1489146580.git.jpinto@synopsys.com>
 <20170310.095011.2233077499571268155.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <peppe.cavallaro@st.com>, <alexandre.torgue@st.com>,
        <niklas.cassel@axis.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.47.9]:55501 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755405AbdCJSA3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 13:00:29 -0500
In-Reply-To: <20170310.095011.2233077499571268155.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Às 5:50 PM de 3/10/2017, David Miller escreveu:
> From: Joao Pinto <Joao.Pinto@synopsys.com>
> Date: Fri, 10 Mar 2017 12:18:25 +0000
> 
>> As agreed with David Miller, this patch-set is the first of 3 to enable
>> multiple queues in stmmac.
> 
> I have one more request to make.
> 
> The name of the driver is "stmmac" therefore I'd like you to use
> "stmmac: " as the subsystem prefix in your Subject lines just as
> everyone else who works on this driver does.  Please don't use
> "stmicro: " thank you.
> 

Ok, I will do that. Thanks.
