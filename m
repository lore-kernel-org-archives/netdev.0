From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [patch 1/1] tcp-patch for net-next
Date: Tue, 25 Jun 2013 15:59:04 +0200
Message-ID: <20130625135904.840700403@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp16.uk.ibm.com ([195.75.94.112]:55062 "EHLO
	e06smtp16.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752287Ab3FYOAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 10:00:39 -0400
Received: from /spool/local
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Tue, 25 Jun 2013 14:55:25 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here is a tcp-patch establishing the TCP Experimental Option Experiment
Identifier for Shared Memory communications over RDMA protocol

shortlog:

Ursula Braun (1)
tcp: introduce TCP experimental option for SMC-R

Thanks,
        Ursula
