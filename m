From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: bridge: remove unnecessary switchdev include
Date: Tue, 08 Sep 2015 22:33:35 -0700 (PDT)
Message-ID: <20150908.223335.1211717852632403759.davem@davemloft.net>
References: <1441504181-20376-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, sfeldma@gmail.com, jiri@resnulli.us
To: vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57602 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751419AbbIIFdg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 01:33:36 -0400
In-Reply-To: <1441504181-20376-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Sat,  5 Sep 2015 21:49:41 -0400

> Remove the unnecessary switchdev.h include from br_netlink.c.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied.
