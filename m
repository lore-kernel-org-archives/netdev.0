From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH] ioc3-eth: Use the instance of net_device_stats from
 net_device.
Date: Mon, 5 Jul 2010 13:55:44 +0100
Message-ID: <20100705125544.GA28849@linux-mips.org>
References: <1278332034-17122-1-git-send-email-segooon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kernel Janitors <kernel-janitors@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Jiri Pirko <jpirko@redhat.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Patrick McHardy <kaber@trash.net>,
        Alexey Dobriyan <adobriyan@gmail.com>,
        linux-mips@linux-mips.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Kulikov Vasiliy <segooon@gmail.com>
Return-path: <linux-mips-bounce@linux-mips.org>
Content-Disposition: inline
In-Reply-To: <1278332034-17122-1-git-send-email-segooon@gmail.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 05, 2010 at 04:13:51PM +0400, Kulikov Vasiliy wrote:

> Since net_device has an instance of net_device_stats,
> we can remove the instance of this from the adapter structure.
> 
> Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>

NACK, your patch doesn't compile.  I'll post a fixed patch in a separate
mail.

  Ralf
