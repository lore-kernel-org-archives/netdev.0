From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] cls_cgroup: unify classid syntax to tc
Date: Thu, 11 Jun 2009 21:36:41 -0700 (PDT)
Message-ID: <20090611.213641.208431667.davem@davemloft.net>
References: <20090611180555.f2c76568.usui@mxm.nes.nec.co.jp>
	<20090611.021347.142243970.davem@davemloft.net>
	<20090612124028.fe4c2100.usui@mxm.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: containers@lists.linux-foundation.org, netdev@vger.kernel.org,
	tgraf@suug.ch, hadi@cyberus.ca, jarkao2@gmail.com
To: usui@mxm.nes.nec.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48723
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751156AbZFLEgj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2009 00:36:39 -0400
In-Reply-To: <20090612124028.fe4c2100.usui@mxm.nes.nec.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Minoru Usui <usui@mxm.nes.nec.co.jp>
Date: Fri, 12 Jun 2009 12:40:28 +0900

> Of course, if read syntax change from decimal expression, there
> isn't compatibility.  But I think it's better to fix this problem.
> What do you think?

I think compatibility is more important than symmetry.
