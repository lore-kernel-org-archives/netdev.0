From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH v0 05/10] arm: orion5x: Add DT include for mv88f5181
Date: Sun, 17 Jul 2016 15:41:45 -0500
Message-ID: <20160717204145.GA17994@rob-hp-laptop>
References: <1468679348-10522-1-git-send-email-jm@lentin.co.uk>
 <1468679348-10522-6-git-send-email-jm@lentin.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Imre Kaloz <kaloz@openwrt.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Jamie Lentin <jm@lentin.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:33463 "EHLO
	mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751174AbcGQUls (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jul 2016 16:41:48 -0400
Content-Disposition: inline
In-Reply-To: <1468679348-10522-6-git-send-email-jm@lentin.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 16, 2016 at 03:29:03PM +0100, Jamie Lentin wrote:
> Signed-off-by: Jamie Lentin <jm@lentin.co.uk>
> ---
>  .../bindings/arm/marvell/marvell,orion5x.txt       |  1 +
>  arch/arm/boot/dts/orion5x-mv88f5181.dtsi           | 35 ++++++++++++++++++++++
>  2 files changed, 36 insertions(+)
>  create mode 100644 arch/arm/boot/dts/orion5x-mv88f5181.dtsi

Acked-by: Rob Herring <robh@kernel.org>
