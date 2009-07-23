From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: Re: [net-next 6/10] bnx2x: Update vlan_features
Date: Thu, 23 Jul 2009 14:30:30 +0300
Message-ID: <4A6849D6.4050200@voltaire.com>
References: <1248191263.18195.49.camel@lb-tlvb-eilong>	<4A683F83.1060701@trash.net> <4A68462C.1080709@Voltaire.com> <4A68479F.1000807@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Patrick McHardy <kaber@trash.net>, Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:17378 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751098AbZGWLaj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jul 2009 07:30:39 -0400
In-Reply-To: <4A68479F.1000807@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

okay, understood. So the patches to bnx2 and bnx2x can/should be made 
simpler and the patch to bonding has to change and include a call to 
netdev_features_change(), Jay, I assume you prefer to do that, if not, 
let me know and I will.

Or.

