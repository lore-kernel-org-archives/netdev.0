From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT PATCH 1/5] igb: link up/down messages must follow a
 specific format
Date: Thu, 27 Nov 2008 03:34:15 -0800 (PST)
Message-ID: <20081127.033415.82840693.davem@davemloft.net>
References: <20081127000206.22431.53339.stgit@gitlost.lost>
	<87r64x30je.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	alexander.h.duyck@intel.com
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42187
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752339AbYK0LeP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 06:34:15 -0500
In-Reply-To: <87r64x30je.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Thu, 27 Nov 2008 11:50:45 +0100

> Jeff Kirsher <jeffrey.t.kirsher@intel.com> writes:
> 
> > From: Alexander Duyck <alexander.h.duyck@intel.com>
> >
> > The system log messages created on a link status change need to follow a
> > specific format to work with tools some customers use.
> 
> It would be better to define standard helper functions that output this
> format somewhere. Then this could be also used in other drivers.

He's already been told this.
