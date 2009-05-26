From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2.6.30] WiMAX pull request
Date: Mon, 25 May 2009 22:56:20 -0700 (PDT)
Message-ID: <20090525.225620.93095319.davem@davemloft.net>
References: <cover.1242980768.git.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wimax@linuxwimax.org
To: inaky@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59454
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751651AbZEZF4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 01:56:21 -0400
In-Reply-To: <cover.1242980768.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Date: Fri, 22 May 2009 01:29:40 -0700

> This pull contains a single patch (bigger than I'd like) that fixes a
> device reset, breaking the connection.
> 
> This caused by asking the device to auto-suspend (go into USB power
> saving) in a bad moment. System suspend/hibernate are not affected.

Pulled, thanks.
