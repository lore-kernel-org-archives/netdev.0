From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] vmxnet3: locking problems in xmit
Date: Mon, 20 Dec 2010 10:44:32 -0800 (PST)
Message-ID: <20101220.104432.39185982.davem@davemloft.net>
References: <20101220130315.GY1936@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sbhatewara@vmware.com, pv-drivers@vmware.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41452
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932815Ab0LTSoD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 13:44:03 -0500
In-Reply-To: <20101220130315.GY1936@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Mon, 20 Dec 2010 16:03:15 +0300

> There were several paths that didn't release their locks.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied.
