From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8168 is needed to enter P-state: Package State 6(pc6)onHaswellhardware
Date: Tue, 7 Oct 2014 22:17:13 +0200
Message-ID: <20141007201713.GB4398@zoreil.com>
References: <542B3829.3010108@crashplan.pro> <20141005165920.GA21926@electric-eye.fr.zoreil.com> <0835B3720019904CB8F7AA43166CEEB2526932@RTITMBSV03.realtek.com.tw> <20141006221307.GB10936@electric-eye.fr.zoreil.com> <0835B3720019904CB8F7AA43166CEEB2526B88@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ceriel Jacobs <linux-ide@crashplan.pro>,
	nic_swsd <nic_swsd@realtek.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pulsar.zoreil.com ([83.167.33.49]:37462 "EHLO pulsar.zoreil.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753329AbaJGUWb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Oct 2014 16:22:31 -0400
Content-Disposition: inline
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB2526B88@RTITMBSV03.realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hayes Wang <hayeswang@realtek.com> :
[...]
> When enabling the ASPM, it would influence the thrpughput. It is hard to
> choose performance or power saving. Therefore, we reserve the config
> to let the user determines it.

Mmmm...

How do Realtek's devices behave if Config{2, 3} + MISC registers are
configured for ASPM whereas PCI config space registers aren't ?

-- 
Ueimor
