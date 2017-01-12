From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH v2 2/2] stmmac: rename it to synopsys
Date: Thu, 12 Jan 2017 16:04:45 +0000
Message-ID: <6da8254b-11b2-aa0d-9640-ca73e30bcc0f@synopsys.com>
References: <dbb59d07-4ab4-37d2-5e70-073091749445@synopsys.com>
 <20170112.102630.1448382649844350511.davem@davemloft.net>
 <3ec17612-255f-5fc7-02c6-9ba5b76d2c09@synopsys.com>
 <20170112.104539.326369092090046644.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <alexandre.torgue@st.com>, <f.fainelli@gmail.com>,
        <lars.persson@axis.com>, <niklass@axis.com>,
        <peppe.cavallaro@st.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay.synopsys.com ([198.182.60.111]:52855 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750734AbdALQEu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 11:04:50 -0500
In-Reply-To: <20170112.104539.326369092090046644.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Às 3:45 PM de 1/12/2017, David Miller escreveu:
> From: Joao Pinto <Joao.Pinto@synopsys.com>
> Date: Thu, 12 Jan 2017 15:39:47 +0000
> 
>> In my understanding the advantage is to prepare the future.
> 
> If the driver is named foo or bar, yet in both cases loads and
> properly attaches to the user's device, the user does not care.

Of course. Although my car works I like to open the hood a see it clean and
organized. Gives the user more confidence.

> 
> Therefore, there is no bonafide benefit to the user.
> 
> You aren't getting past that point.
> 
> You also are not addressing the pain this will cause for long
> term maintainence of this driver.

I am aware. I can co-maintain it if current maintainers wish it, no problem with
that. My activity at Synopsys in mainline contribution, so it is part of my job.

> 
> I'm the one who does all of the backporting of stmmac bug fixes to
> -stable, so I for one care a lot about this.
> 
> You are making more work for me and lots of other people by renaming
> this driver and I don't think you are considering that at all.
> 

I understand, it is a lot of work. I volunteer to help.

Joao
