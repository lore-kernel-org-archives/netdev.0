From: Amr Bekhit <amrbekhit@gmail.com>
Subject: Re: Davicom DM9162 PHY supported in the kernel?
Date: Tue, 24 May 2016 17:09:35 +0100
Message-ID: <CAOLz05o5SELBH6LovChQrFXQWXOZANhrYrTNcuktM_nKnp10VQ@mail.gmail.com>
References: <CAOLz05qgn2-9Qxm1cR7mXa67GAwD2SGbMnbeeEBrYeSPsBexuw@mail.gmail.com>
 <5717C45F.30205@gmail.com> <CAOLz05pidfdJXR58a+xjvp02EyPhUJnz9odpM-VFtkCQ2bhtNQ@mail.gmail.com>
 <20160503153659.GA29815@lunn.ch> <CAOLz05r-JEk2JV7PONsPhkaxCUankB6XThFgo4DO+gCf1p9c4g@mail.gmail.com>
 <20160509120634.GQ7972@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:35872 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751425AbcEXQJ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2016 12:09:56 -0400
Received: by mail-wm0-f48.google.com with SMTP id n129so138637376wmn.1
        for <netdev@vger.kernel.org>; Tue, 24 May 2016 09:09:55 -0700 (PDT)
In-Reply-To: <20160509120634.GQ7972@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

> How about adding a printk() in genphy_read_status().

Would you be able to point me to some more information about these
status bits, please? I'm struggling to find information about what
they are, where I read them from, etc. I'm happy to write some debug
printk's in the code, I just don't know where to get information about
these status bits.
