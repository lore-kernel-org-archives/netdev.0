From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v3 net-next 5/8] net/ncsi: Dump NCSI packet statistics
Date: Thu, 20 Apr 2017 18:43:06 -0700
Message-ID: <1492738986.30293.16.camel@perches.com>
References: <1492498295-14385-1-git-send-email-gwshan@linux.vnet.ibm.com>
         <1492498295-14385-6-git-send-email-gwshan@linux.vnet.ibm.com>
         <20170420.132103.454438573956782815.davem@davemloft.net>
         <20170420233812.GA7223@gwshan>
         <0289f0b2-36a8-f4a0-ef15-808aa66528fa@gmail.com>
         <20170421004435.GA18727@gwshan>
         <6b310c50-bab4-b5a7-0317-5a430c55917a@gmail.com>
         <20170421013527.GA26300@gwshan>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        kubakici@wp.pl
To: Gavin Shan <gwshan@linux.vnet.ibm.com>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0149.hostedemail.com ([216.40.44.149]:46884 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1034278AbdDUBnM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 21:43:12 -0400
In-Reply-To: <20170421013527.GA26300@gwshan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-04-21 at 11:35 +1000, Gavin Shan wrote:
> Yes, it's definitely good idea to cover everything using one interface.
> It's for sure that the statistics collected by hardware should be dumped
> by ethtool in future. I will move functionalities introduced by this
> patchset to ethtool as well, as Dave suggested in another thread. Hope
> Joe has no objection on this.

Of course not.
