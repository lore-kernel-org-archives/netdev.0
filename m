From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 5/12] forcedeth: optimized routines
Date: Tue, 23 Jan 2007 01:08:01 -0500
Message-ID: <45B5A641.2050700@pobox.com>
References: <45B3F2ED.8080402@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45581 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933034AbXAWGIM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jan 2007 01:08:12 -0500
To: Ayaz Abdulla <aabdulla@nvidia.com>
In-Reply-To: <45B3F2ED.8080402@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ayaz Abdulla wrote:
> This patch breaks up the routines into two versions, one for legacy
> descriptor versions (ver 1 and ver 2) and one for desc ver 3. This will
> make the new desc functions more leaner and further reductions will be
> made in next few patches.
> 
> Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>

applied patches 5-9 to #upstream


