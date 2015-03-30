From: Petri Gynther <pgynther@google.com>
Subject: Re: [PATCH net-next 0/3] net: bcmgenet: code cleanup
Date: Mon, 30 Mar 2015 00:00:27 -0700
Message-ID: <CAGXr9JEZWBcJ0Obsr+Pw=a7Lkac=Wu9i8t=qDT3KPTOKsv0Y=w@mail.gmail.com>
References: <20150328055034.10049220209@puck.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jaedon Shin <jaedon.shin@gmail.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f43.google.com ([209.85.192.43]:35085 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751792AbbC3HA2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 03:00:28 -0400
Received: by qgh3 with SMTP id 3so164161332qgh.2
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 00:00:28 -0700 (PDT)
In-Reply-To: <20150328055034.10049220209@puck.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm going to add a few more patches to this series. Sending patch v2
out shortly.

On Fri, Mar 27, 2015 at 10:50 PM, Petri Gynther <pgynther@google.com> wrote:
> Three patches to clean up bcmgenet code:
> 1. add UMAC_IRQ_RXDMA_DONE and UMAC_IRQ_TXDMA_DONE
> 2. remove __bcmgenet_fini_dma()
> 3. fix bcmgenet_open()
