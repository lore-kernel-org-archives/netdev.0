From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch] netlink: fix a limit in NETLINK_LIST_MEMBERSHIPS
Date: Fri, 13 Nov 2015 22:53:09 +0300
Message-ID: <20151113195309.GV7289@mwanda>
References: <20151113142044.GA1445@mwanda>
 <CANq1E4Rh60iS6WRq6xypV_ahG5N=uErL_hMnVcncc=DTSPvdUw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Johannes Berg <johannes.berg@intel.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Florian Westphal <fw@strlen.de>,
	netdev <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: David Herrmann <dh.herrmann@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:43583 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754225AbbKMTx4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2015 14:53:56 -0500
Content-Disposition: inline
In-Reply-To: <CANq1E4Rh60iS6WRq6xypV_ahG5N=uErL_hMnVcncc=DTSPvdUw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oh.  Crap...  My mistake.  Sorry for the noise.  The original code is
fine.

regards,
dan carpenter
