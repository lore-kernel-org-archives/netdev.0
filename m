From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdev: dm9000: require compat net dev ops
Date: Thu, 11 Jun 2009 16:49:08 -0700 (PDT)
Message-ID: <20090611.164908.11590745.davem@davemloft.net>
References: <1244761350-2823-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vapier.adi@gmail.com
To: vapier@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40646
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756073AbZFKXtF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 19:49:05 -0400
In-Reply-To: <1244761350-2823-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier@gentoo.org>
Date: Thu, 11 Jun 2009 19:02:30 -0400

> The dm9000 driver hasn't been upgraded yet, so select the compat net dev
> ops option for now.
> 
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>

This config option no longer exists in the networking tree.
