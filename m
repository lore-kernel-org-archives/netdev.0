From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] ipconfig tweaks
Date: Fri, 17 Apr 2009 03:45:12 -0700 (PDT)
Message-ID: <20090417.034512.40940557.davem@davemloft.net>
References: <1239874659-19273-1-git-send-email-dmitry.krivoschekov@gmail.com>
	<20090417.012316.209396377.davem@davemloft.net>
	<49E85348.8080906@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dmitry.krivoschekov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46504
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757709AbZDQKpU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 06:45:20 -0400
In-Reply-To: <49E85348.8080906@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Krivoschekov <dmitry.krivoschekov@gmail.com>
Date: Fri, 17 Apr 2009 14:00:40 +0400

> Why don't let users to optimize boot-up time?

Because a generic scheme that works automatically is 1,000
times better than random kernel command line parms.
