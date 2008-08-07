From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/4] forcedeth: fix rx error policy
Date: Thu, 07 Aug 2008 02:11:30 -0400
Message-ID: <489A9212.9040800@pobox.com>
References: <4899CD17.4030105@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47894 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753791AbYHGGLj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Aug 2008 02:11:39 -0400
In-Reply-To: <4899CD17.4030105@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ayaz Abdulla wrote:
> This patch enforces a stricter policy on rx errors. The driver needs to 
> verify whether there are multiple rx errors versus a single error.
> 
> Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>

applied 1-4


