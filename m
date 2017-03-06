From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] mac80211: Use setup_timer instead of init_timer
Date: Mon, 06 Mar 2017 13:36:28 +0100
Message-ID: <1488803788.5761.9.camel@sipsolutions.net>
References: <20170303124535.30125-1-jslaby@suse.cz>
         <1488803104.5761.6.camel@sipsolutions.net>
         <7545a8ad-ec74-ed01-d84d-9ef4528b21df@suse.cz>
         (sfid-20170306_133512_596414_00F06E73)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
        =?UTF-8?Q?Ond=C5=99ej_Lyson=C4=9Bk?= <ondrej.lysonek@seznam.cz>,
        "David S. Miller" <davem@davemloft.net>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:46828 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752899AbdCFMgf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 6 Mar 2017 07:36:35 -0500
In-Reply-To: <7545a8ad-ec74-ed01-d84d-9ef4528b21df@suse.cz> (sfid-20170306_133512_596414_00F06E73)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Not really. This is one of assignments for students I lead, so this
> is done by hand every end of winter semester (Note the From line.)

You really should teach them about coccinelle then :-)

> > Care to send a patch for that one too?
> 
> I am just a forwarder, he received this request too, so you can try
> to persuade him :).

Hah ok. I thought you actually cared about the end result ;)

johannes
