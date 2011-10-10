From: Stephen Hemminger <shemminger@vyatta.com>
Subject: RFC - dnsmasq fix for IPv6 DAD
Date: Mon, 10 Oct 2011 15:24:30 -0700
Message-ID: <20111010152430.013e7c11@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Simon Kelley <simon@thekelleys.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49484 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752839Ab1JJWYg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Oct 2011 18:24:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The developer of dnsmasq has a pre-release version that fixes
the issue with DAD and devices with tentative addresses.

Please try the following:

http://www.thekelleys.org.uk/dnsmasq/test-releases/dnsmasq-2.59test1.tar.gz

Thanks Simon.
