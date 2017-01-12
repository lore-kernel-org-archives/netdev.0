From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH] synopsys: remove dwc_eth_qos driver
Date: Thu, 12 Jan 2017 15:46:31 +0000
Message-ID: <0eb32fee-0354-522d-72c4-3d1105ec04ed@synopsys.com>
References: <2d50f9fea61de2eb082b217d435334d40e3e01ad.1484214626.git.jpinto@synopsys.com>
 <20170112.102802.1485105708725148022.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <lars.persson@axis.com>, <niklass@axis.com>,
        <peppe.cavallaro@st.com>, <alexandre.torgue@st.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay.synopsys.com ([198.182.47.9]:58300 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751015AbdALPqg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 10:46:36 -0500
In-Reply-To: <20170112.102802.1485105708725148022.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Às 3:28 PM de 1/12/2017, David Miller escreveu:
> 
> There is no driver named "synopsys", therefore "synopsys: " is not an
> appropriate subsystem prefix.
> 
> Subsystem prefixes have to refer to real names in the source tree in
> one form or another.
> 
> I know you guys really want to rename the stmmac driver to that, but
> no agreement has occurred on that issue and therefore assuming it
> has happened is not appropriate.
> 

:) I put synopsys because it is the name of the folder where dwc_eth_qos.c is.
Do you want me to change the title to "dwc_eth_qos: remove dwc_eth_qos driver"?

Hope we can meet in a LinuxCon soon and have a talk, for you to know me and this
way you will see that I am a guy that is only focused in producing work the best
way possible, and nothing else.

Thanks,
Joao
