From: Haggai Eran <haggaie@mellanox.com>
Subject: Re: [PATCH v1 11/12] IB/cma: Share ib_cm_ids between rdma_cm_ids
Date: Tue, 14 Jul 2015 11:47:58 +0300
Message-ID: <55A4CCBE.3060403@mellanox.com>
References: <1434976961-27424-1-git-send-email-haggaie@mellanox.com>
 <1434976961-27424-12-git-send-email-haggaie@mellanox.com>
 <20150713180605.GI23832@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Doug Ledford <dledford@redhat.com>, <linux-rdma@vger.kernel.org>,
	<netdev@vger.kernel.org>, Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0078.outbound.protection.outlook.com ([157.55.234.78]:3824
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752049AbbGNIsq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jul 2015 04:48:46 -0400
In-Reply-To: <20150713180605.GI23832@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/07/2015 21:06, Jason Gunthorpe wrote:
> On Mon, Jun 22, 2015 at 03:42:40PM +0300, Haggai Eran wrote:
>> Use ib_cm_id_create_and_listen to create listening IB CM IDs or share
>       ^^^^^^^^^^^^^^^^^^^^^^^^^^^
> Is that the wrong name? ib_cm_insert_listen perhaps?

Yes, I missed that. Thanks.
