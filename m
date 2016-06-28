From: Moritz Fischer <moritz.fischer@ettus.com>
Subject: Re: Supporting C45 PHY without ID registers
Date: Mon, 27 Jun 2016 18:50:30 -0700
Message-ID: <CAAtXAHeWgcJoR4CeTsN202+zvh7cNyZJeR_u2WoAVgo_i24dpA@mail.gmail.com>
References: <CAAtXAHdfL07C+p-FcafHL5s0Noqh4Br1VP6dcyBr89wWidvsJQ@mail.gmail.com>
 <20160628005618.GC26597@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f42.google.com ([209.85.213.42]:33940 "EHLO
	mail-vk0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752050AbcF1Buc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 21:50:32 -0400
Received: by mail-vk0-f42.google.com with SMTP id c2so3234849vkg.1
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 18:50:31 -0700 (PDT)
In-Reply-To: <20160628005618.GC26597@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

On Mon, Jun 27, 2016 at 5:56 PM, Andrew Lunn <andrew@lunn.ch> wrote:

> Does it have any ID registers at all?

There is a vendor specific (to my knowledge) register at device 1
register 65535 ([1]) that could be read back. I haven't seen anyone
else do that.

Thanks,

Moritz

[1] http://www.xilinx.com/support/documentation/ip_documentation/ten_gig_eth_pcs_pma/v6_0/pg068-ten-gig-eth-pcs-pma.pdf
