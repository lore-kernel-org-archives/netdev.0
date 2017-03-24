From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [v2,net-next,1/3] net: stmmac: enable multiple buffers
Date: Fri, 24 Mar 2017 12:17:36 +0100
Message-ID: <20170324111736.GB22281@lunn.ch>
References: <1eb1ee4c84f61ff8dbc3f398f2e3f9b0bea3ee30.1489766674.git.jpinto@synopsys.com>
 <20170323171725.GA12548@ulmo.ba.sec>
 <2ec8451b-4d12-d7ea-a2ce-4f1add382df4@synopsys.com>
 <20170324074255.GB16730@lunn.ch>
 <cb5f5af2-6375-111b-e1aa-da48b5c42595@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thierry Reding <thierry.reding@gmail.com>, davem@davemloft.net,
        peppe.cavallaro@st.com, alexandre.torgue@st.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org
To: Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59654 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932442AbdCXLRu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 24 Mar 2017 07:17:50 -0400
Content-Disposition: inline
In-Reply-To: <cb5f5af2-6375-111b-e1aa-da48b5c42595@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Yes it would be fantastic to have a set of boards, but I rarely see this in any
> maintainer :).

Being a Marvell SoC and switch maintainer, i have around a dozen
boards. Some i got some simply by asking the manufacture, others i
purchased. I don't think i'm in the minority here. Without having
access to a number of different hardwares, i don't feel i would be
doing my work properly.

> I try as hard as I can to network with people and try to minimize this
> situations, but when there is so many different setups using a driver with diff
> configurations, situations like this can happen, but I am here to help debugging
> and solving them.

You made a move to rename stmmac to synopsys not long ago. It gave the
impression that synopsis wants to take over this driver. If there are
a number of different configurations, who better than synopsys to
actually properly test these configurations? If you ask around, i'm
sure people will send you hardware.

     Andrew
