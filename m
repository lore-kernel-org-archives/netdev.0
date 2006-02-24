From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 00/01] pktgen: Lindent run.
Date: Thu, 23 Feb 2006 17:17:46 -0800 (PST)
Message-ID: <20060223.171746.81607534.davem@davemloft.net>
References: <20060123134419.efc0c80e.lcapitulino@mandriva.com.br>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	robert.olsson@its.uu.se
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932370AbWBXBRm@vger.kernel.org>
To: lcapitulino@mandriva.com.br
In-Reply-To: <20060123134419.efc0c80e.lcapitulino@mandriva.com.br>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Luiz Fernando Capitulino <lcapitulino@mandriva.com.br>
Date: Mon, 23 Jan 2006 13:44:19 -0200

> 
>  This patch is not in-lined because it's 120K bytes long, you can found it at:
> 
> http://www.cpu.eti.br/patches/pktgen_lindent_1.patch

Not found:

davem@sunset:~/src/GIT/net-2.6.17$ wget http://www.cpu.eti.br/patches/pktgen_lindent_1.patch
--17:16:50--  http://www.cpu.eti.br/patches/pktgen_lindent_1.patch
           => `pktgen_lindent_1.patch'
Resolving www.cpu.eti.br... 209.59.143.183
Connecting to www.cpu.eti.br|209.59.143.183|:80... connected.
HTTP request sent, awaiting response... 404 Not Found
17:16:50 ERROR 404: Not Found.

Anyways, can you please regenerate these 4 patches against
net-2.6.17, as I put in Arthur's race fix and it will certainly
conflict with these.

Sorry for taking so long to get to this :-(
