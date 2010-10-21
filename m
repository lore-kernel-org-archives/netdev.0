From: Tom Herbert <therbert@google.com>
Subject: [PATCH 0/2 v3] xps: Transmit Packet Steering
Date: Thu, 21 Oct 2010 13:17:06 -0700 (PDT)
Message-ID: <alpine.DEB.1.00.1010211306110.8397@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: eric.dumazet@gmail.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:23321 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755684Ab0JUURO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 16:17:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

New version transmit packet steering.  Separated out generic
changed in dev_pick_tx to its own patch.
