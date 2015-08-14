From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rocker: print switch ID consistent with
 phys_switch_id sysfs node
Date: Thu, 13 Aug 2015 17:06:11 -0700 (PDT)
Message-ID: <20150813.170611.600644348284285701.davem@davemloft.net>
References: <1439430253-49275-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40186 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753344AbbHNAGM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 20:06:12 -0400
In-Reply-To: <1439430253-49275-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Wed, 12 Aug 2015 18:44:13 -0700

> From: Scott Feldman <sfeldma@gmail.com>
> 
> On sucessful probe, driver prints the switch ID.  This patch changes the
> format of the printed ID to match what's used in sysfs phys_switch_id node.
> 
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Applied.
