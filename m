From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC 5/8] net-next: ralink: add support for rt3050 family
Date: Mon, 23 Nov 2015 00:16:01 +0100
Message-ID: <20151122231601.GA9582@lunn.ch>
References: <1448181658-38111-1-git-send-email-blogic@openwrt.org>
 <1448181658-38111-5-git-send-email-blogic@openwrt.org>
 <20151122163632.GA7110@lunn.ch>
 <56521250.1060001@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Michael Lee <igvtee@gmail.com>,
	Felix Fietkau <nbd@openwrt.org>,
	"Steven Liu (?????????)" <steven.liu@mediatek.com>,
	"Fred Chang (?????????)" <Fred.Chang@mediatek.com>
To: John Crispin <blogic@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:39239 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752784AbbKVXQG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Nov 2015 18:16:06 -0500
Content-Disposition: inline
In-Reply-To: <56521250.1060001@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hi Andrew,
> 
> we have had a switch layer inside openwrt called swconfig for several
> years. at the moment i have an add-on patch in openwrt to provide an
> userland interface via that layer.

Hi John

I know of swconfig.  However, it has been NACKed for mainline. So you
either need to do switchdev or DSA for controlling switches in
mainline.

	Andrew
