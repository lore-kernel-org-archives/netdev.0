From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH]: was Re: LLTX and netif_stop_queue
Date: Thu, 20 Jan 2005 14:16:56 -0500
Message-ID: <41F003A8.3050806@pobox.com>
References: <5cac192f0412230110628749e3@mail.gmail.com>	<41CAF444.3000305@trash.net>	<5cac192f04122408102129af43@mail.gmail.com>	<1104240717.1100.66.camel@jzny.localdomain>	<5cac192f0501021530672a908a@mail.gmail.com>	<1104764660.1048.578.camel@jzny.localdomain>	<52brc68q05.fsf@topspin.com>	<5cac192f05010308414a25b548@mail.gmail.com>	<527jmu8nbw.fsf@topspin.com>	<5cac192f0501030907c755135@mail.gmail.com>	<20050103171227.GD7370@esmail.cup.hp.com>	<1104812294.1085.53.camel@jzny.localdomain>	<20050119144711.3fdd3d93.davem@davemloft.net>	<20050119151853.259de49a@dxpl.pdx.osdl.net>	<20050119164640.6c67bdfa.davem@davemloft.net>	<52r7kgu5n5.fsf@topspin.com> <20050119230526.393a5184.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <roland@topspin.com>, shemminger@osdl.org, hadi@cyberus.ca,
        iod00d@hp.com, eric.lemoine@gmail.com, netdev@oss.sgi.com, ak@suse.de,
        openib-general@openib.org, kaber@trash.net
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050119230526.393a5184.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Reminder:  double-check that the locking rules in 
Documentation/networking/netdevices.txt still apply; update the text 
file where you changed things.
