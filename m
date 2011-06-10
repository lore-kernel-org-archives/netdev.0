From: Russell King <rmk@arm.linux.org.uk>
Subject: [PATCH 0/3] Fixes for ARM/ebsa110 am79c961 driver
Date: Fri, 10 Jun 2011 11:51:22 +0100
Message-ID: <20110610105122.GA27087@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:35111 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755257Ab1FJKvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 06:51:32 -0400
Received: from flint.arm.linux.org.uk ([2002:4e20:1eda:1:201:2ff:fe14:8fad])
	by caramon.arm.linux.org.uk with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.72)
	(envelope-from <rmk@arm.linux.org.uk>)
	id 1QUzJI-0006Py-Uz
	for netdev@vger.kernel.org; Fri, 10 Jun 2011 11:51:29 +0100
Received: from rmk by flint.arm.linux.org.uk with local (Exim 4.69)
	(envelope-from <rmk@flint.arm.linux.org.uk>)
	id 1QUzJE-0008He-LX
	for netdev@vger.kernel.org; Fri, 10 Jun 2011 11:51:24 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches fix some of the more serious issues discovered
with GCC 4 and the ARM EBSA110 am79c961 ethernet driver last weekend
while upgrading my firewall to 2.6.39.

-- 
Russell King
