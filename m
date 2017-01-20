From: marcelo.leitner@gmail.com
Subject: Re: [PATCH][V2] net: sctp: fix array overrun read on sctp_timer_tbl
Date: Fri, 20 Jan 2017 14:51:35 -0200
Message-ID: <20170120165135.GB669@localhost.localdomain>
References: <20170120134542.21104-1-colin.king@canonical.com>
 <20170120135845.GT3781@localhost.localdomain>
 <20170120.113209.1764653226397979876.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: colin.king@canonical.com, vyasevich@gmail.com,
        nhorman@tuxdriver.com, linux-sctp@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170120.113209.1764653226397979876.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 20, 2017 at 11:32:09AM -0500, David Miller wrote:
> From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> Date: Fri, 20 Jan 2017 11:58:45 -0200
> 
> > Not sure I can add the Fixes tag for you here, but:
> > Fixes: 7b9438de0cd4 ("sctp: add stream reconf timer")
> > Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> 
> FWIW, patchwork doesn't notice updated Fixes: tags like this but I
> try to do so myself and the effort is definitely appreciated.

Ok, good to know, thanks.

> 
> We need a V3 of this change anyways, see the build failure I reported
> for V2, so Colin can add the Fixes: tag there explicitly.
> 

Replied this one in there.

  Marcelo
