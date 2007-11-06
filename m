From: Dave Johnson <djohnson+linux-kernel@sw.starentnetworks.com>
Subject: RE: [PATCH 2/2] NET: Re-add VLAN tag for devices incapable of keeping it
Date: Tue, 6 Nov 2007 13:34:25 -0500
Message-ID: <18224.46001.836006.507154@zeus.sw.starentnetworks.com>
References: <78C9135A3D2ECE4B8162EBDCE82CAD77027E9D5E@nekter>
	<78C9135A3D2ECE4B8162EBDCE82CAD77027E9E9E@nekter>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<bguo@sw.starentnetworks.com>
To: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.starentnetworks.com ([12.38.223.203]:33821 "EHLO
	mx0.starentnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752613AbXKFSeb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2007 13:34:31 -0500
In-Reply-To: <78C9135A3D2ECE4B8162EBDCE82CAD77027E9E9E@nekter>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ramkrishna Vepa writes:
> Dave,
> 
> If you can remove the patch for the s2io driver, we can submit a patch
> that can dynamically program Xframe to strip or not strip the vlan tag
> based on whether the vlan group is not NULL or NULL respectively. For
> this, we have to modify the initialization as well as the vlan
> registration.

Sure, not having this hardware I didn't want to attempt a complicated
change.  I'll let you take care of this.

-- 
Dave Johnson
Starent Networks

