From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH net-next] ethernet: fix min/max MTU typos
Date: Mon, 24 Oct 2016 23:07:22 -0400
Message-ID: <20161025030722.GN42084@redhat.com>
References: <20161024144226.70480d4b@kant>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Thomas Falcon <tlfalcon@linux.vnet.ibm.com>,
        linux-kernel@vger.kernel.org
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161024144226.70480d4b@kant>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 24, 2016 at 02:42:26PM +0200, Stefan Richter wrote:
> Fixes: d894be57ca92('ethernet: use net core MTU range checking in more drivers')
> CC: Jarod Wilson <jarod@redhat.com>
> CC: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
> Signed-off-by: Stefan Richter <stefanr@s5r6.in-berlin.de>

Wuf. Thank you, Stefan. Way too many bleeding eyeball hours staring at all
those changes.

Acked-by: Jarod Wilson <jarod@redhat.com>

-- 
Jarod Wilson
jarod@redhat.com
