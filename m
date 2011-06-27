From: "Gole, Anant" <anantgole@ti.com>
Subject: RE: [RFC 26/72] arm: Move the ARM/ACORN drivers
Date: Mon, 27 Jun 2011 08:40:20 +0530
Message-ID: <2A3DCF3DA181AD40BDE86A3150B27B6B037558A181@dbde02.ent.ti.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1309010363-22750-27-git-send-email-jeffrey.t.kirsher@intel.com>
 <201106251648.03574.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Govindarajan, Sriramakrishnan" <srk@ti.com>,
	"Hegde, Vinay" <vinay.hegde@ti.com>,
	"Chemparathy, Cyril" <cyril@ti.com>,
	Wan ZongShun <mcuos.com@gmail.com>,
	Lennert Buytenhek <kernel@wantstofly.org>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Chaithrika U S <chaithrika@ti.com>
To: Arnd Bergmann <arnd@arndb.de>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Russell King <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:37275 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755066Ab1F0DKx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jun 2011 23:10:53 -0400
In-Reply-To: <201106251648.03574.arnd@arndb.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>It doesn't seem logical to group drivers that are used on ARM under
>the architecture when the hardware is not actually made by ARM Ltd.
>
>TI also produces chips with the C6x architecture, which will be
>supported
>in Linux in the future. It could well be that there is a version that
>uses the davinci ethernet mac. You also have a TI directory.
>

IMO davinci_emac driver should go under /ethernet/ti/

