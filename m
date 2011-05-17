From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: [stable submission] vmxnet3: Fix inconsistent LRO state after initialization
Date: Tue, 17 May 2011 12:52:30 +0200
Message-ID: <4DD2536E.1000008@intra2net.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rs04.intra2net.com ([85.214.66.2]:35678 "EHLO
	rs04.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753379Ab1EQKwd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 06:52:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi greg k-h,

please include commit ebde6f8acba92abfc203585198a54f47e83e2cd0
"vmxnet3: Fix inconsistent LRO state after initialization"

in 2.6.37 / 2.6.38 stable.


Kernel 2.6.32 first included the vmxnet3 driver and I've checked
that the patch applies to 2.6.32.40 and 2.6.35.13, so it might be
worth to include it in all maintained kernels.

Best regards,
Thomas Jarosch
