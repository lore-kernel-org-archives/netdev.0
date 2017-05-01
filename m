From: Johan Hedberg <johan.hedberg@gmail.com>
Subject: Re: pull request: bluetooth-next 2017-04-30
Date: Mon, 1 May 2017 22:21:54 +0300
Message-ID: <20170501192154.GA3423@x1c>
References: <20170430140928.GA2753@x1c>
 <20170430.230336.142225761153252889.davem@davemloft.net>
 <20170501184221.GA2093@x1c>
 <20170501.145019.1619484787513762409.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:33175 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750819AbdEATWF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 15:22:05 -0400
Content-Disposition: inline
In-Reply-To: <20170501.145019.1619484787513762409.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 01, 2017, David Miller wrote:
> From: Johan Hedberg <johan.hedberg@gmail.com>
> Date: Mon, 1 May 2017 21:42:21 +0300
> 
> > Hi Dave,
> > 
> > On Sun, Apr 30, 2017, David Miller wrote:
> >> From: Johan Hedberg <johan.hedberg@gmail.com>
> >> Date: Sun, 30 Apr 2017 17:09:28 +0300
> >> 
> >> > Here's one last batch of Bluetooth patches in the bluetooth-next tree
> >> > targeting the 4.12 kernel.
> >> > 
> >> >  - Remove custom ECDH implementation and use new KPP API instead
> >> >  - Add protocol checks to hci_ldisc
> >> >  - Add module license to HCI UART Nokia H4+ driver
> >> >  - Minor fix for 32bit user space - 64 bit kernel combination
> >> > 
> >> > Please let me know if there are any issues pulling. Thanks.
> >> 
> >> Pulled, thanks Johan.
> > 
> > Thanks, however I don't see the patches in net-next yet. I have seen
> > other patches go in there since your response though. Cause for concern?
> 
> Shuld be there now.

Looks good now. Thanks.

Johan
