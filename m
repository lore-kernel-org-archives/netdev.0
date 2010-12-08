From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] l2tp: Fix modalias of l2tp_ip
Date: Wed, 08 Dec 2010 10:25:34 -0800 (PST)
Message-ID: <20101208.102534.59676955.davem@davemloft.net>
References: <1291639152-26608-1-git-send-email-mmarek@suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jchapman@katalix.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mmarek@suse.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1291639152-26608-1-git-send-email-mmarek@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Marek <mmarek@suse.cz>
Date: Mon,  6 Dec 2010 13:39:12 +0100

> Using the SOCK_DGRAM enum results in
> "net-pf-2-proto-SOCK_DGRAM-type-115", so use the numeric value like it
> is done in net/dccp.
> 
> Signed-off-by: Michal Marek <mmarek@suse.cz>

Applied, thank you.
