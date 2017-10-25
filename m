From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC] net/unix_diag: Provide UDIAG_SHOW_VFS2 attribute to fetch
 complete inode number
Date: Wed, 25 Oct 2017 17:02:34 +0300
Message-ID: <20171025140234.GB26429@uranus>
References: <20171024214814.GO5343@uranus>
 <85bmkvcoxw.fsf@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NETDEV <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Andrey Vagin <avagin@openvz.org>,
        "David S. Miller" <davem@davemloft.net>,
        Pavel Emelyanov <xemul@virtuozzo.com>
To: Roman Mashak <mrv@mojatatu.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <85bmkvcoxw.fsf@mojatatu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 25, 2017 at 09:55:07AM -0400, Roman Mashak wrote:
> 
> I think __zero should be explicitly set to 0.

It will be by compiler default.
