From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH 1/2] tun: Use memdup_user() rather than duplicating its
 implementation
Date: Sat, 20 Aug 2016 14:47:18 +0300
Message-ID: <20160820144718.6f204a5e@halley>
References: <566ABCD9.1060404@users.sourceforge.net>
        <9cf06275-924d-6c22-d8a8-f733a03cca23@users.sourceforge.net>
        <a2ee9925-1241-0328-6d35-9a9c9f567ea4@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Jason Wang <jasowang@redhat.com>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Mike Rapoport <rppt@linux.vnet.ibm.com>,
        Paolo Abeni <pabeni@redhat.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a2ee9925-1241-0328-6d35-9a9c9f567ea4@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Sat, 20 Aug 2016 09:34:56 +0200 SF Markus Elfring <elfring@users.sourceforge.net> wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Sat, 20 Aug 2016 08:54:15 +0200
> 
> Reuse existing functionality from memdup_user() instead of keeping
> duplicate source code.
> 
> This issue was detected by using the Coccinelle software.
> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>

Reviewed-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
