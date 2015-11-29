From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next V1 13/18] net/mlx5: E-Switch, Add SR-IOV (FDB)
 support
Date: Sun, 29 Nov 2015 19:07:14 +0200
Message-ID: <565B30C2.2070007@mellanox.com>
References: <201511300041.HLRu7EyR%fengguang.wu@intel.com>
 <alpine.DEB.2.10.1511291725070.2713@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Don Dutile <ddutile@redhat.com>,
	Doug Ledford <dledford@redhat.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>, <ronye@mellanox.com>,
	<kbuild-all@01.org>
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0083.outbound.protection.outlook.com ([157.55.234.83]:62432
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751013AbbK2RXT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Nov 2015 12:23:19 -0500
In-Reply-To: <alpine.DEB.2.10.1511291725070.2713@hadrien>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/29/2015 6:27 PM, Julia Lawall wrote:
> Please check line 442.  It seems clear that match_c was intended.

Sure, will fix that and run more static checkers before submitting V2, seems
like checkpatch, smatch and sparse are not enough... thanks for pointing 
this out.

Or.
