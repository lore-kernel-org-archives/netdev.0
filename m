From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] packet: Don't write vnet header beyond end of buffer
Date: Tue, 29 Aug 2017 15:10:21 -0700 (PDT)
Message-ID: <20170829.151021.699244485897285329.davem@davemloft.net>
References: <20170828182941.10677-1-bpoirier@suse.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        willemb@google.com
To: bpoirier@suse.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170828182941.10677-1-bpoirier@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin Poirier <bpoirier@suse.com>
Date: Mon, 28 Aug 2017 14:29:41 -0400

> ... which may happen with certain values of tp_reserve and maclen.
> 
> Fixes: 58d19b19cd99 ("packet: vnet_hdr support for tpacket_rcv")
> Signed-off-by: Benjamin Poirier <bpoirier@suse.com>
> Cc: Willem de Bruijn <willemb@google.com>

Applied and queued up for -stable.
