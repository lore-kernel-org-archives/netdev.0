From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/3] forcedeth: disable msix
Date: Tue, 20 Feb 2007 11:26:32 -0500
Message-ID: <45DB2138.1040508@garzik.org>
References: <45D9B3F7.4080801@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44633 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030217AbXBTQ0i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 11:26:38 -0500
In-Reply-To: <45D9B3F7.4080801@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ayaz Abdulla wrote:
> There seems to be an issue when both MSI-X is enabled and NAPI is 
> configured. This patch disables MSI-X until the issue is root caused.
> 
> Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>

ACK patches 2-3

Will await resend of entire patch series, after patch #1 is updated


