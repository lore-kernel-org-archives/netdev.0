From: "Padmalochan Moharana" <padmalochan.moharana@Nethawk.EXFO.com>
Subject: FW: Regarding VLAN TAG in wireshark trace
Date: Thu, 29 Apr 2010 10:33:44 +0530
Message-ID: <135E20FB988B4900857B06D06C26AC08@nethawk.fi>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from levi.nethawkgroup.com ([194.100.156.5]:51566 "HELO
	levi.nethawkgroup.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1758649Ab0D3RZR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 13:25:17 -0400
Received: from jopo.nethawk.fi (jopo.nethawk.fi [194.100.156.10])
	by mailgw.nethawk.fi (Postfix) with ESMTP id BA7226F028
	for <netdev@vger.kernel.org>; Thu, 29 Apr 2010 08:02:34 +0300 (EEST)
Received: from BHULA022 (10.16.16.166) by jopo.nethawk.fi (7.0.008)
        id 4BD82DCF00000D4F for netdev@vger.kernel.org; Thu, 29 Apr 2010 08:03:46 +0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
The wireshark captured the message without any
VLAN tag because the driver stripped the VLAN tag of the received message.So
wireshark does not see any VLAN tag in the message. I think any other system
setting or driver is required to capture the VLAN tag. So please let me know
which driver deliver the message without stripping the VLAN tag of the
message.

Please post to netdev@vger.kernel.org

Br,
Padmalochan Moharana


