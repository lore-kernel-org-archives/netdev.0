From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC 0/7] network device irq naming
Date: Tue, 21 Jun 2011 10:05:41 -0700
Message-ID: <20110621170541.309890798@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49487 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756958Ab1FURHW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jun 2011 13:07:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a proposal for a wrapper routine to cause
network devices to have standard convention for IRQ naming.

Includes a subset of devices to show how it would be used
and some of the existing problems.


