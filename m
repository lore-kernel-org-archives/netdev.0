From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next v10 0/8] openvswitch: NAT support
Date: Tue, 15 Mar 2016 01:01:24 +0100
Message-ID: <20160315000124.GA1710@salvia>
References: <1457636063-92746-1-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	dev@openvswitch.org
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56229 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932175AbcCOABa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2016 20:01:30 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 8F475114F47
	for <netdev@vger.kernel.org>; Tue, 15 Mar 2016 01:01:27 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 80CB8DA8FA
	for <netdev@vger.kernel.org>; Tue, 15 Mar 2016 01:01:27 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id A481DDA38A
	for <netdev@vger.kernel.org>; Tue, 15 Mar 2016 01:01:25 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <1457636063-92746-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 10, 2016 at 10:54:15AM -0800, Jarno Rajahalme wrote:
> This series adds NAT support to openvswitch kernel module.  A few
> changes are needed to the netfilter code to facilitate this (patches
> 1-2/8).  Patches 3-7 make the openvswitch kernel module ready for the
> patch 8 that adds the NAT support by calling into netfilter NAT code
> from the openvswitch conntrack action.

Series applied, thanks Jarno.
