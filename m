From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] qlcnic: Fixes and debug support
Date: Wed, 03 Aug 2011 16:30:58 -0700 (PDT)
Message-ID: <20110803.163058.1039782232013988525.davem@davemloft.net>
References: <3C193C58-33FE-4ECF-A6AA-F7D0C3907C0D@qlogic.com>
	<20110801.173840.1120019952254994551.davem@davemloft.net>
	<EA95D2DB-162E-4FBD-8DC1-F4DE41EB7ACE@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com
To: anirban.chakraborty@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52454 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756324Ab1HCXbC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2011 19:31:02 -0400
In-Reply-To: <EA95D2DB-162E-4FBD-8DC1-F4DE41EB7ACE@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Date: Wed, 3 Aug 2011 13:20:00 -0700

> Do you want me to resend the patch series for net-2.6? It was my
> mistake to specify net-next instead of net-2.6

The debug support patches are not appropriate for plain 'net',
only the pure most critical bug fixes are.
