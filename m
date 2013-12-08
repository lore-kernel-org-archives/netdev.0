From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 09/14] i40e: Enable all PCTYPEs except FCOE for RSS.
Date: Sat, 07 Dec 2013 22:09:09 -0800 (PST)
Message-ID: <20131207.220909.1073991599965800636.davem@davemloft.net>
References: <1386382643-29055-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1386382643-29055-10-git-send-email-jeffrey.t.kirsher@intel.com>
	<52A36235.1040406@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, anjali.singhai@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	jesse.brandeburg@intel.com
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54585 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751492Ab3LHF76 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Dec 2013 00:59:58 -0500
In-Reply-To: <52A36235.1040406@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Sat, 07 Dec 2013 22:00:21 +0400

>    This line has no place in the upstream patches, and I'm seeing it in
>    several patches of this series.

I told Jeff that this was OK, other entities such as Google do it too.
