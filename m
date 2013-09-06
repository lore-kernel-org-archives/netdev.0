From: David Miller <davem@davemloft.net>
Subject: Re: [E1000-devel] [net-next v5 8/8] i40e: include i40e in kernel
 proper
Date: Fri, 06 Sep 2013 14:01:41 -0400 (EDT)
Message-ID: <20130906.140141.2245821068783126791.davem@davemloft.net>
References: <1378447278-13998-9-git-send-email-jeffrey.t.kirsher@intel.com>
	<20130905231436.761d03c3@nehalam.linuxnetplumber.net>
	<C0F8C5F1-0D98-4297-ACC9-55BB9C889FEB@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, jeffrey.t.kirsher@intel.com,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60219 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751518Ab3IFSBp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Sep 2013 14:01:45 -0400
In-Reply-To: <C0F8C5F1-0D98-4297-ACC9-55BB9C889FEB@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I'm kind of getting sick of the "we'll fix it in a follow up patch"
talk.

Please rename this Kbuild file to the normal Makefile instead of
trying to be different from every single other driver in the
networking for the sake of an issue that is your, and your problem
alone.

You guys should really be grateful that anyone at all not being paid
to do so is reviewing such a huge body of code for you, rather than
complaining that all the issues weren't discovered the first time
this series was posted.

Please start being more reasonable about this situation.

Thank you.
