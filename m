From: Pekka Pietikainen <pp@ee.oulu.fi>
Subject: Re: [PATCH] b44 ethtool_ops
Date: Fri, 7 May 2004 14:12:36 +0300
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040507111236.GA29330@ee.oulu.fi>
References: <4097FADB.4090105@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Netdev <netdev@oss.sgi.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Arjan van de Ven <arjanv@redhat.com>,
	Pekka Pietikainen <pp@netppl.fi>, Pavel Machek <pavel@suse.cz>,
	Andrew Morton <akpm@osdl.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S263183AbUEGLNW@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <4097FADB.4090105@pobox.com>
List-Id: netdev.vger.kernel.org

On Tue, May 04, 2004 at 04:19:39PM -0400, Jeff Garzik wrote:
> Testing requested.
> 
> Should see no ethtool behavior change, positive or negative.
Well, driver still works, advertised link modes does look a bit odd though
(ethtool-1.8-3.1)

Settings for eth1:
        Supported ports: [ MII ]
        Supported link modes:   10baseT/Half 10baseT/Full 
                                100baseT/Half 100baseT/Full 
        Supports auto-negotiation: Yes
        Advertised link modes:  1000baseT/Full 
        Advertised auto-negotiation: Yes
        Speed: 100Mb/s
        Duplex: Full
        Port: Twisted Pair
        PHYAD: 1
        Transceiver: internal
        Auto-negotiation: on
        Current message level: 0x000000ff (255)
        Link detected: yes
