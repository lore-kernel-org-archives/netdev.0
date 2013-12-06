From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] qlge: Bug fixes
Date: Thu, 05 Dec 2013 20:34:01 -0500 (EST)
Message-ID: <20131205.203401.2117852520866182573.davem@davemloft.net>
References: <1386285084-25250-1-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com,
	Dept-HSGLinuxNICDev@qlogic.com
To: jitendra.kalsaria@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60350 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751191Ab3LFBeC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 20:34:02 -0500
In-Reply-To: <1386285084-25250-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Date: Thu, 5 Dec 2013 18:11:21 -0500

> This patch series include bug fixes.
> o Receive frame error stats were getting overwritten by other driver statistics.
> o User is allowed to enable/disable rx/tx vlan acceleration independently.

Series applied, thanks.
