From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH V3 net-next] ixgbe: Avoid unaligned access in ixgbe_atr()
 for LLC packets
Date: Wed, 16 Mar 2016 19:01:57 -0400
Message-ID: <20160316230157.GK21307@oracle.com>
References: <20160314194716.GM5084@oracle.com>
 <1458169132.2878.25.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	alexander.duyck@gmail.com, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, bruce.w.allan@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:27098 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932632AbcCPXCT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 19:02:19 -0400
Content-Disposition: inline
In-Reply-To: <1458169132.2878.25.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (03/16/16 15:58), Jeff Kirsher wrote:
>=20
> This does not apply since Alex Duyck beat you to the fix. =A0Here is =
the
> patch he submitted on 3/15 which corrects the issue. =A0So I am dropp=
ing
> your patch from the queue.
>=20

That's weird because Alexander was reviewing my fix on the various
lists yesterday, so he could have just told me about this.

But, whatever.

--sowmini
