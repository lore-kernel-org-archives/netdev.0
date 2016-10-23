From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH -next] net: dsa: mv88e6xxx: use setup_timer to simplify
 the code
Date: Sun, 23 Oct 2016 17:54:40 +0200
Message-ID: <20161023155440.GA1110@lunn.ch>
References: <1477146480-28003-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:51990 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755833AbcJWPys (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 23 Oct 2016 11:54:48 -0400
Content-Disposition: inline
In-Reply-To: <1477146480-28003-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 22, 2016 at 02:28:00PM +0000, Wei Yongjun wrote:
> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> Use setup_timer function instead of initializing timer with the function
> and data fields.
> 
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
