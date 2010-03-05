From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: Re: [PATCH V3 4/8] llc: use limited socket backlog
Date: Fri, 5 Mar 2010 10:00:59 -0300
Message-ID: <20100305130059.GD16539@ghostprotocols.net>
References: <1267761707-15605-1-git-send-email-yi.zhu@intel.com>
 <1267761707-15605-2-git-send-email-yi.zhu@intel.com>
 <1267761707-15605-3-git-send-email-yi.zhu@intel.com>
 <1267761707-15605-4-git-send-email-yi.zhu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Zhu Yi <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:42871 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751996Ab0CENBD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Mar 2010 08:01:03 -0500
Received: by gwb15 with SMTP id 15so1792401gwb.19
        for <netdev@vger.kernel.org>; Fri, 05 Mar 2010 05:01:03 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1267761707-15605-4-git-send-email-yi.zhu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Fri, Mar 05, 2010 at 12:01:43PM +0800, Zhu Yi escreveu:
> Make llc adapt to the limited socket backlog change.
> 
> Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
> Signed-off-by: Zhu Yi <yi.zhu@intel.com>

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
