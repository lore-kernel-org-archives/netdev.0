From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH net-next] core: remove unneded headers for net cgroup
 controllers.
Date: Mon, 15 Feb 2016 13:32:16 -0500
Message-ID: <20160215183216.GI3965@htj.duckdns.org>
References: <1455496783-8478-1-git-send-email-rami.rosen@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, nhorman@tuxdriver.com,
	tgraf@suug.ch
To: Rami Rosen <rami.rosen@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:33356 "EHLO
	mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751153AbcBOScT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 13:32:19 -0500
Received: by mail-qk0-f195.google.com with SMTP id q184so5617733qkb.0
        for <netdev@vger.kernel.org>; Mon, 15 Feb 2016 10:32:19 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1455496783-8478-1-git-send-email-rami.rosen@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 15, 2016 at 02:39:43AM +0200, Rami Rosen wrote:
> commit 3ed80a6 (cgroup: drop module support) made including 
> module.h redundant in the net cgroup controllers, 
> netclassid_cgroup.c and netprio_cgroup.c. This patch 
> removes them.
> 
> Signed-off-by: Rami Rosen <rami.rosen@intel.com>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun
