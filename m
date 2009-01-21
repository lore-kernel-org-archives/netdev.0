From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] e1000: drop lltx, remove unnecessary lock
Date: Wed, 21 Jan 2009 14:43:08 -0800 (PST)
Message-ID: <20090121.144308.67788152.davem@davemloft.net>
References: <20090121083329.538.67223.stgit@lost.foo-projects.org>
	<20090121083407.538.47112.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52435
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753638AbZAUWnG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 17:43:06 -0500
In-Reply-To: <20090121083407.538.47112.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 21 Jan 2009 00:34:07 -0800

> LLTX is deprecated, don't use it.  This completes the removal of LLTX from
> the Intel Network drivers.
> 
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
