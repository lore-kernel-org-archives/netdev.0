From: mschmidt@redhat.com
Subject: [patch 0/2] rebinding tunnels to interfaces
Date: Thu, 13 Dec 2007 14:37:48 +0100
Message-ID: <20071213133748.862042979@redhat.com>
Cc: davem@davemloft.net, kaber@trash.net, mmaslano@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52147 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752419AbXLMNj1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2007 08:39:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These two patches allow rebinding of GRE and SIT tunnels to interfaces using
ip tun change <tunnel> dev <iface>
A similar change was already done for IPIP tunnels.

Michal
-- 
