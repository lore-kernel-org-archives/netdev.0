From: David Miller <davem@davemloft.net>
Subject: Re: [1/4 v2] Remove unused zero-copy code from velocity NIC driver.
Date: Thu, 23 Jul 2009 19:02:51 -0700 (PDT)
Message-ID: <20090723.190251.111990099.davem@davemloft.net>
References: <20090721.123322.118453668.davem@davemloft.net>
	<20090723.155855.108555685.davem@davemloft.net>
	<20090724004449.GA16422@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42502
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750847AbZGXCCp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2009 22:02:45 -0400
In-Reply-To: <20090724004449.GA16422@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Thu, 23 Jul 2009 20:44:49 -0400

> Previous changes broke compilation with CONFIG_PM disabled.
> This widens the ifdefs to cover the functions that only get called
> within the suspend/resume routines.
> 
> Signed-off-by: Dave Jones <davej@redhat.com>

Applied, thanks Dave.
