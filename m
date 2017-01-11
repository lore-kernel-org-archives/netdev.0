From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH v2 0/2] remove dwc_eth_qos and rename stmicro/stmmac
Date: Wed, 11 Jan 2017 16:19:19 +0000
Message-ID: <bb15d840-10ec-7249-98c5-3a48d0174ba6@synopsys.com>
References: <0dcdcb5f-200b-b130-9a67-774639353114@st.com>
 <20170111.095256.1057845755758556047.davem@davemloft.net>
 <329b0d8c-4cda-7238-c229-d69ac251f26b@synopsys.com>
 <20170111.102000.1291650495305959047.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <alexandre.torgue@st.com>, <lars.persson@axis.com>,
        <niklass@axis.com>, <peppe.cavallaro@st.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay2.synopsys.com ([198.182.60.111]:34112 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751671AbdAKQTY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 11:19:24 -0500
In-Reply-To: <20170111.102000.1291650495305959047.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Às 3:20 PM de 1/11/2017, David Miller escreveu:
> From: Joao Pinto <Joao.Pinto@synopsys.com>
> Date: Wed, 11 Jan 2017 15:06:55 +0000
> 
>> The goal of this work is to improve code organization and future merge of other
>> Synopsys Ethernet IP driver that will be able to merge into this "synopsys
>> driver bundle". That is why I volunteered to merge the dwc qos axis' driver into
>> stmmac.
> 
> Then I want to see an ACK from Alexandre and Peppe for this renaming
> patch set.
> 

Just a side question. My commits are assuming my username instead of my name.
Did you ever had a similar issue? My gitconfig:

> [user]
>         email = jpinto@synopsys.com
>         name = Joao Pinto
> [format]
>         signoff = true
>         thread = true
> [sendemail]
>         smtpEncryption = tls
>         smtpServer = <SERVER>
>         smtpUser = <SERVER_USER>
>         confirm = auto
> [core]
>         excludesfile = /path/.gitignore [pack]
>         windowMemory = 2048m
> [diff]
>         renames = copy

Thanks,
Joao
