From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] [resend] fix non-mergeable buffers packet too large
	error handling
Date: Tue, 18 May 2010 06:12:52 +0300
Message-ID: <20100518031252.GA23764@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.osdl.org, davem@davemloft.net
To: David L Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38656 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752113Ab0ERDQ6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 May 2010 23:16:58 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DaveM, just to clarify, this patch is on top of the series
we are working on with David L Stevens. It's not for your net tree.

-- 
MST
