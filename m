From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: tun: use new api ethtool_{get|set}_link_ksettings
Date: Fri, 10 Mar 2017 14:46:02 -0800
Message-ID: <1489185962.28631.29.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1489180687-19623-1-git-send-email-tremyfr@gmail.com>
         <20170310235719-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Philippe Reynes <tremyfr@gmail.com>, davem@davemloft.net,
        edumazet@google.com, pabeni@redhat.com,
        fgao@48lvckh6395k16k5.yundunddos.com,
        elfring@users.sourceforge.net, jarno@ovn.org,
        rppt@linux.vnet.ibm.com, jarod@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36483 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932705AbdCJWqG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 17:46:06 -0500
In-Reply-To: <20170310235719-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-03-10 at 23:57 +0200, Michael S. Tsirkin wrote:
> On Fri, Mar 10, 2017 at 10:18:07PM +0100, Philippe Reynes wrote:
> > The ethtool api {get|set}_settings is deprecated.
> > We move this driver to new api {get|set}_link_ksettings.
> > 
> > As I don't have the hardware,
> 
> What kind of hardware?

TGIF ;)
