From: David Miller <davem@davemloft.net>
Subject: Re: pull request [net]: batman-adv 20150804
Date: Tue, 04 Aug 2015 12:40:40 -0700 (PDT)
Message-ID: <20150804.124040.324026088945274161.davem@davemloft.net>
References: <1438706134-3492-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: antonio@meshcoding.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54515 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753782AbbHDTkl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 15:40:41 -0400
In-Reply-To: <1438706134-3492-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@meshcoding.com>
Date: Tue,  4 Aug 2015 18:35:20 +0200

> here you have our batch of fixes intended for net/linux-4.2.

Sorry, you can't come to me this late in the -RC series with such
a huge collection of bug fixes.

Break out the most important critical ones, and only submit those.
The rest will have to go via net-next.
