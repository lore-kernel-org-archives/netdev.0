From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 22 Apr 2013 20:38:46 -0400 (EDT)
Message-ID: <20130422.203846.798313857495836249.davem@davemloft.net>
References: <20130419125304.9980f9b037abf00bef7b6f8c@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, ordex@autistici.org,
	lindner_marek@yahoo.de, martin@hundeboll.net
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20130419125304.9980f9b037abf00bef7b6f8c@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 19 Apr 2013 12:53:04 +1000

> Today's linux-next merge of the net-next tree got a conflict in
> net/batman-adv/routing.c between commit fe8a93b95145 ("batman-adv: make
> is_my_mac() check for the current mesh only") from the net tree and
> commits f86ce0ad107b ("batman-adv: Return reason for failure in
> batadv_check_unicast_packet()") and 612d2b4fe0a1 ("batman-adv: network
> coding - save overheard and tx packets for decoding") from the net-next
> tree.
> 
> I fixed it up (see below) and can carry the fix as necessary (no action
> is required).

I've merged net into net-next and added all the necessary fixups
in the merge commit.

Thanks!
