From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [ethtool PATCH] ethtool: Add Direct Attach to the available connector
 ports
Date: Sun, 29 Nov 2009 06:03:41 -0500
Message-ID: <4B12550D.6050107@garzik.org>
References: <20091125101315.24481.11759.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, shemminger@vyatta.com, netdev@vger.kernel.org,
	gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45597 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752712AbZK2LDk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Nov 2009 06:03:40 -0500
In-Reply-To: <20091125101315.24481.11759.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/25/2009 05:13 AM, Jeff Kirsher wrote:
> From: PJ Waskiewicz<peter.p.waskiewicz.jr@intel.com>
>
> This adds Direct Attach SFP+ types to the connector ports
> for the GSET mode.
>
> Signed-off-by: Peter P Waskiewicz Jr<peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
> ---
>
>   ethtool-copy.h |    3 +++
>   ethtool.c      |    6 ++++++
>   2 files changed, 9 insertions(+), 0 deletions(-)

applied


