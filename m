From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/16][pull request] Intel Wired LAN Driver Update
Date: Tue, 21 Jun 2011 03:04:43 -0700 (PDT)
Message-ID: <20110621.030443.907704723206051603.davem@davemloft.net>
References: <1308645228-32444-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52996 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932111Ab1FUKEr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 06:04:47 -0400
In-Reply-To: <1308645228-32444-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 21 Jun 2011 01:33:32 -0700

> The following series contains update for e1000, igb, ixgbevf and ixgbe.
> 
> e1000 and igb: conversion to ndo_fix_features from Michal
> ixgbevf: fix function declarations and removal of un-necessary &'s
> ixgbe: Mainly cleanup of DCB code and the addition of Dell CEM support.
> 
> Dropped the problem patch from Vasu that was previously submitted in the last
> patch series.
> 
> The following are changes since commit 9f6ec8d697c08963d83880ccd35c13c5ace716ea:
>   Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6
> and are available in the git repository at:
>   master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6 master

Pulled, thanks Jeff.
