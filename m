From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: [RFC][PATCH][IPSEC][0/3]inter address family ipsec tunnel
Date: Fri, 29 Dec 2006 14:47:02 +0900
Message-ID: <20061229144702.11ff0478.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi004.linux-ipv6.org ([203.178.140.4]:46517 "EHLO
	miyazawa.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754074AbWL2Fza (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Dec 2006 00:55:30 -0500
To: Miika Komu <miika@iki.fi>, Diego Beltrami <Diego.Beltrami@hiit.fi>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I fixed the compile issue when we configure IPv6 as a module.

[1/3] exporting xfrm_state_afinfo
[2/3] supporting IPv6 over IPv4 IPsec
[3/3] supporting IPv4 over IPv6 IPsec

These patches can be applied to linux-2.6.20-rc2.

Thank you,

--
Kazunori Miyazawa
