From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/06]: VLAN TCI truncation fixes
Date: Sun, 06 Jul 2008 20:49:02 -0700 (PDT)
Message-ID: <20080706.204902.245651270.davem@davemloft.net>
References: <48714BA3.3080102@trash.net>
	<4871769E.2020305@garzik.org>
	<48717B49.1060804@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com,
	ionut@cs.columbia.edu, baum@tehutinetworks.net, andy@greyhouse.net
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45808
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753866AbYGGDtE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jul 2008 23:49:04 -0400
In-Reply-To: <48717B49.1060804@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 07 Jul 2008 04:11:21 +0200

> Jeff Garzik wrote:
> > Patrick McHardy wrote:
> >>      e1000: don't truncate VLAN TCI with VLAN stripping
> >>      e1000e: don't truncate VLAN TCI with VLAN stripping
> >>      igb: don't truncate VLAN TCI with VLAN stripping
> >>      ixgb: don't truncate VLAN TCI with VLAN stripping
> >>      starfire: don't truncate VLAN TCI with VLAN stripping
> >>      tehuti: don't truncate VLAN TCI with VLAN stripping
> >
> > Acked-by: Jeff Garzik <jgarzik@redhat.com>
> Thanks.
> >
> > Though I would suggest combining all these patches into a single 
> > patch, since they constitute a single logical change, and each change 
> > is self-contained and small.
> 
> Attached is a combined patch with these 6 patches.

Applied, thanks everyone.
