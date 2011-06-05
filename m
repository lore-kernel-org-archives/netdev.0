From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qlcnic: Fix bug in FW queue dump
Date: Sun, 05 Jun 2011 14:18:33 -0700 (PDT)
Message-ID: <20110605.141833.1002239618486867590.davem@davemloft.net>
References: <1307054541-11178-1-git-send-email-anirban.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com
To: anirban.chakraborty@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51920 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755330Ab1FEVSi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2011 17:18:38 -0400
In-Reply-To: <1307054541-11178-1-git-send-email-anirban.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Date: Thu,  2 Jun 2011 15:42:21 -0700

> Due to a change in FW template, a bug was introduced in dump queue entries. This is
> fixed by reinitializing queue address before looping for each que dump operation.
> 
> Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>

Applied.

