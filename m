From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [net-next PATCH] mlx4/mlx5: Use dma_wmb/rmb where appropriate
Date: Tue, 24 Mar 2015 11:26:49 +0200
Message-ID: <55112DD9.9030105@mellanox.com>
References: <20150323171300.1117.85908.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	Amir Vadai <amirv@mellanox.com>, Eli Cohen <eli@mellanox.com>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0095.outbound.protection.outlook.com ([157.55.234.95]:46544
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752189AbbCXJ0y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Mar 2015 05:26:54 -0400
In-Reply-To: <20150323171300.1117.85908.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/23/2015 7:23 PM, Alexander Duyck wrote:
> [...] I don't have any adapters supported by these drivers so I am unable to do anything more than build test the changes.

Alex, I'll provide you details on HW access for cards provided to 
red-hat so you can test the changes.
