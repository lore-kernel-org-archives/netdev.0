From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] igb: igb should not flag lltx
Date: Wed, 21 Jan 2009 14:42:56 -0800 (PST)
Message-ID: <20090121.144256.30881321.davem@davemloft.net>
References: <20090121083329.538.67223.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52427
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753277AbZAUWmy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 17:42:54 -0500
In-Reply-To: <20090121083329.538.67223.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 21 Jan 2009 00:33:29 -0800

> Igb has flags enabling lltx but this is a holdover from the earlier e1000
> driver which the igb driver was based off of.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
