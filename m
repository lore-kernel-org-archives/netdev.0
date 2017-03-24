From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [v2,net-next,1/3] net: stmmac: enable multiple buffers
Date: Fri, 24 Mar 2017 17:09:38 +0000
Message-ID: <742f3185-1b4e-f801-5b5e-cc835953ff0c@synopsys.com>
References: <20170324074255.GB16730@lunn.ch>
 <cb5f5af2-6375-111b-e1aa-da48b5c42595@synopsys.com>
 <20170324111736.GB22281@lunn.ch>
 <20170324.100557.1391035515160209574.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <Joao.Pinto@synopsys.com>, <thierry.reding@gmail.com>,
        <peppe.cavallaro@st.com>, <alexandre.torgue@st.com>,
        <f.fainelli@gmail.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.47.9]:48599 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935857AbdCXRKh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 13:10:37 -0400
In-Reply-To: <20170324.100557.1391035515160209574.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello David,

Às 5:05 PM de 3/24/2017, David Miller escreveu:
> From: Andrew Lunn <andrew@lunn.ch>
> Date: Fri, 24 Mar 2017 12:17:36 +0100
> 
>>> Yes it would be fantastic to have a set of boards, but I rarely see this in any
>>> maintainer :).
>>
>> Being a Marvell SoC and switch maintainer, i have around a dozen
>> boards. Some i got some simply by asking the manufacture, others i
>> purchased. I don't think i'm in the minority here. Without having
>> access to a number of different hardwares, i don't feel i would be
>> doing my work properly.
>>
>>> I try as hard as I can to network with people and try to minimize this
>>> situations, but when there is so many different setups using a driver with diff
>>> configurations, situations like this can happen, but I am here to help debugging
>>> and solving them.
>>
>> You made a move to rename stmmac to synopsys not long ago. It gave the
>> impression that synopsis wants to take over this driver. If there are
>> a number of different configurations, who better than synopsys to
>> actually properly test these configurations? If you ask around, i'm
>> sure people will send you hardware.
> 
> I completely agree with everything Andrew is saying here.
> 

I'll maintain the driver if everyone agrees with it, no problem, mas I would
like to hear from Peppe and Alex, since they are the current maintainers.

HW testing would be nice, but hard to justify investing in one shot, so it would
be great to receive hardware to make tests if the companies wish it.

About the problems in the last patch I am going to send a 2 patch set with 2
fixes, lets see if stuff gets better.

Thnaks
Joao
