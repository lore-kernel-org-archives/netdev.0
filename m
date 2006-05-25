From: David Miller <davem@davemloft.net>
Subject: Re: reminder, 2.6.18 window...
Date: Thu, 25 May 2006 14:07:36 -0700 (PDT)
Message-ID: <20060525.140736.48529487.davem@davemloft.net>
References: <20060525192239.GB29024@ipom.com>
	<20060525.132928.115910730.davem@davemloft.net>
	<20060525210412.GC29024@ipom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bcook@bpointsys.com, billfink@mindspring.com, jeff@garzik.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:37005
	"EHLO sunset.sfo1.dsl.speakeasy.net") by vger.kernel.org with ESMTP
	id S1030414AbWEYVHb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 May 2006 17:07:31 -0400
To: phil@ipom.com
In-Reply-To: <20060525210412.GC29024@ipom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Phil Dibowitz <phil@ipom.com>
Date: Thu, 25 May 2006 14:04:12 -0700

> why would specifically not support a _feature_ of the hardware.

Sparc64 chips support a hash table like hw assist feature for TLB
reloading, I didn't use it for 8+ years and went with a virtual page
table approach instead.

I mean, your statement is totally meaningless.  Just because the
hardware can do something, doesn't mean we have any reason to use that
functionality.
