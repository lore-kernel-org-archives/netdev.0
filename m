From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] atl1c: disable L1/L0s when link detected
Date: Tue, 28 Apr 2009 01:54:11 -0700 (PDT)
Message-ID: <20090428.015411.167936727.davem@davemloft.net>
References: <1240897323258-git-send-email-jie.yang@atheros.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bjoern.kiefer@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jie.yang@atheros.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37598
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753080AbZD1IyR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 04:54:17 -0400
In-Reply-To: <1240897323258-git-send-email-jie.yang@atheros.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <jie.yang@atheros.com>
Date: Tue, 28 Apr 2009 13:42:03 +0800

> Disable L1/L0s when link detected. We enable L1/L0s when link connected
> before, but there is some hareware error on some platform. So just diable
> this feature when link connected. This feature is about power saving.
> 
> Signed-off-by: Jie Yang <jie.yang@atheros.com>

Applied.
