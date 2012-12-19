From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] qlcnic: fix unused variable warnings
Date: Wed, 19 Dec 2012 12:43:07 -0800 (PST)
Message-ID: <20121219.124307.789475398027109497.davem@davemloft.net>
References: <1355853591-29917-1-git-send-email-sony.chacko@qlogic.com>
	<1355853591-29917-2-git-send-email-sony.chacko@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	shahed.shaikh@qlogic.com
To: sony.chacko@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49324 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755351Ab2LSUnI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 15:43:08 -0500
In-Reply-To: <1355853591-29917-2-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>
Date: Tue, 18 Dec 2012 12:59:50 -0500

> From: Shahed Shaikh <shahed.shaikh@qlogic.com>
> 
> qlcnic_hw.c:370: warning: variable cmd_desc set but not used
> qlcnic_hw.c:368: warning: variable consumer set but not used
> qlcnic_main.c:448: warning: variable ref_count set but not used
> qlcnic_main.c:534: warning: variable mem_base set but not used
> qlcnic_ctx.c:137: warning: variable tmp_tmpl set but not used
> qlcnic_ctx.c:133: warning: variable version set but not used
> qlcnic_minidump.c:200: warning: variable opcode set but not used
> 
> Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
> Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>

Applied.
