From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: linux-next: manual merge of the net-next tree with the nettree
Date: Tue, 12 Jan 2016 11:12:33 +0200
Message-ID: <20160112091233.GB12607@colbert.idosch.org>
References: <20160112131507.4509e7bf@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-next@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Jiri Pirko <jiri@mellanox.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0071.outbound.protection.outlook.com ([157.55.234.71]:18976
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S934608AbcALJNZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jan 2016 04:13:25 -0500
Content-Disposition: inline
In-Reply-To: <20160112131507.4509e7bf@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jan 12, 2016 at 04:15:07AM IST, sfr@canb.auug.org.au wrote:
>Hi all,
>
>Today's linux-next merge of the net-next tree got a conflict in:
>
>  drivers/net/ethernet/mellanox/mlxsw/spectrum.h
>
>between commit:
>
>  366ce6031529 ("mlxsw: spectrum: Add FDB lock to prevent session interleaving")
>
>from the net tree and commit:
>
>  0d65fc13042f ("mlxsw: spectrum: Implement LAG port join/leave")
>
>from the net-next tree.
>
>I fixed it up (see below) and can carry the fix as necessary (no action
>is required).

Acked-by: Ido Schimmel <idosch@mellanox.com>

Thanks!
