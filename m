From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 2.6.26 1/3] RDMA/cxgb3: QP flush fixes
Date: Fri, 02 May 2008 10:58:10 -0700
Message-ID: <adamyn84mh9.fsf@cisco.com>
References: <20080502161741.30500.95337.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	general@lists.openfabrics.org
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3.cisco.com ([171.71.176.72]:35786 "EHLO
	sj-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755951AbYEBR6M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 13:58:12 -0400
In-Reply-To: <20080502161741.30500.95337.stgit@dell3.ogc.int> (Steve Wise's
	message of "Fri, 02 May 2008 11:17:41 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

thanks, applied all 3... (1/3 was against a slightly old tree, so I had
to fix up __FUNCTION__ -> __func__ in the context of the diffs)
