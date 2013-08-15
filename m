From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: proc_fs: trivial: print UIDs as unsigned
 int
Date: Thu, 15 Aug 2013 14:38:06 -0700 (PDT)
Message-ID: <20130815.143806.1656287595009345039.davem@davemloft.net>
References: <bee30aaa49e84c82c8a7ca9939e7321e2c0a741d.1376566630.git.ffusco@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ffusco@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46375 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752662Ab3HOViH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 17:38:07 -0400
In-Reply-To: <bee30aaa49e84c82c8a7ca9939e7321e2c0a741d.1376566630.git.ffusco@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francesco Fusco <ffusco@redhat.com>
Date: Thu, 15 Aug 2013 13:42:14 +0200

> UIDs are printed in the proc_fs as signed int, whereas
> they are unsigned int.
> 
> Signed-off-by: Francesco Fusco <ffusco@redhat.com>

Applied, thanks.
