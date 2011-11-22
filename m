From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [GIT PULL v2] Open vSwitch
Date: Tue, 22 Nov 2011 15:18:54 -0800
Message-ID: <20111122151854.198da33d@nehalam.linuxnetplumber.net>
References: <1321911029-20707-1-git-send-email-jesse@nicira.com>
	<20111122.155006.361847516719132107.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jesse@nicira.com, netdev@vger.kernel.org, dev@openvswitch.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53049 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752753Ab1KVXS5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Nov 2011 18:18:57 -0500
In-Reply-To: <20111122.155006.361847516719132107.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Maybe someone with more insight than me can explain the relationship
between Openflow and Open vSwitch. It maybe that the portability
of Openflow makes the old qdisc, classifiers to use/implement.
