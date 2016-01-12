From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 12 Jan 2016 22:58:11 +1100
Message-ID: <20160112225811.2c70c1a4@canb.auug.org.au>
References: <20160112131505.2228f559@canb.auug.org.au>
	<20160112091102.GA12607@colbert.idosch.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-next@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Jiri Pirko <jiri@mellanox.com>
To: Ido Schimmel <idosch@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160112091102.GA12607@colbert.idosch.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Ido,

On Tue, 12 Jan 2016 11:11:02 +0200 Ido Schimmel <idosch@mellanox.com> wrote:
>
> The lock can be moved further down, just before mlxsw_reg_sfd_pack.
> Other than that everything looks fine. Thank you!

Thanks, I wasn't sure but I will do that tomorrow (unless Dave beats me to it).

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
