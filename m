From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/8] bna: Driver Fixes and Support for Re-architecture
Date: Wed, 27 Jul 2011 22:32:31 -0700 (PDT)
Message-ID: <20110727.223231.1088299143542685793.davem@davemloft.net>
References: <1311732648-29876-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adapter_linux_open_src_team@brocade.com
To: rmody@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38675 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754484Ab1G1Fde (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 01:33:34 -0400
In-Reply-To: <1311732648-29876-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>
Date: Tue, 26 Jul 2011 19:10:40 -0700

>    This patch-set consists of few fixes, HW reg consolidation and adds support
>    for re-architecture and re-organisation of the driver.

Please do not mix bug fixes and feature changes.

If you do this, I can't put the bug fixes into the current release.

Seperate out the real pure bug fixes into a seperate series against
the main 'net' GIT tree.

Then you can submit your feature changes and cleanups seperately for
'net-next'
