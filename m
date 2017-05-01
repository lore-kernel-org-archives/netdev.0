From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: How does vlan driver pass vlan info to the h/w ethernet driver
Date: Mon, 1 May 2017 21:29:57 +0200
Message-ID: <20170501192957.GA18265@lunn.ch>
References: <CABM+yxkiOpOs5b5MM6MD4woz5R2-4_gf=t=8THXb3p=wuwTtXg@mail.gmail.com>
 <20170501143703.GA1285@lunn.ch>
 <CABM+yxmdJD2k1kA+fY9Yva24oB8BuDDhS-FQdY2EJM1ghf6xWw@mail.gmail.com>
 <20170501.105736.157375316602250235.davem@davemloft.net>
 <CABM+yxnbLPjoq4E2Z3d2Jc5qUvN_TWUb6rQpjDWCTs=9j0ce3A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: carl h <heyen2000@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47428 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751769AbdEATaA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 1 May 2017 15:30:00 -0400
Content-Disposition: inline
In-Reply-To: <CABM+yxnbLPjoq4E2Z3d2Jc5qUvN_TWUb6rQpjDWCTs=9j0ce3A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 01, 2017 at 02:26:52PM -0400, carl h wrote:
> It appears that the switchdev driver model was introduced after 2.6.39
> which is the
> kernel version that I'm using unfortunately.

We cannot help you much is you are using an ancient kernel. Please
upgrade.

	Andrew
