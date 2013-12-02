From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v4] xen-netback: fix fragment detection in checksum
 setup
Date: Mon, 02 Dec 2013 13:46:19 -0500 (EST)
Message-ID: <20131202.134619.345791067738711031.davem@davemloft.net>
References: <1386005715-27566-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	zoltan.kiss@citrix.com, wei.liu2@citrix.com,
	ian.campbell@citrix.com, david.vrabel@citrix.com
To: paul.durrant@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52893 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751975Ab3LBSqV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 13:46:21 -0500
In-Reply-To: <1386005715-27566-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


You sent two copies of this patch, is there a difference between
them?
