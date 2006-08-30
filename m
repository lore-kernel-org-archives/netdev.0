From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] Various NetLabel fixes and cleanups
Date: Tue, 29 Aug 2006 17:56:44 -0700 (PDT)
Message-ID: <20060829.175644.66176288.davem@davemloft.net>
References: <20060829144251.452774000@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, jmorris@namei.org,
	sds@tycho.nsa.gov, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:16857
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750844AbWH3A4m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 20:56:42 -0400
To: paul.moore@hp.com
In-Reply-To: <20060829144251.452774000@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: paul.moore@hp.com
Date: Tue, 29 Aug 2006 10:42:51 -0400

> This patchset contains a series of small patches to fix a bug and some general
> ugliness from the original author (that moron ...).  All of the following
> patches are against David's net-2.6.19 tree.
> 
> Please consider these for 2.6.19, thanks.

Applied to net-2.6.19, thanks a lot Paul.

Does the bug fix in that first patch fix the ssh problem?
