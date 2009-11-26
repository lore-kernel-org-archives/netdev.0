From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCHv3 0/4] macvlan: add vepa and bridge mode
Date: Thu, 26 Nov 2009 17:26:17 +0100
Message-ID: <4B0EAC29.60601@trash.net>
References: <1259251631-11617-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Anna Fischer <anna.fischer@hp.com>, netdev@vger.kernel.org,
        bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
        virtualization@lists.linux-foundation.org,
        Mark Smith <lk-netdev@lk-netdev.nosense.org>,
        Gerhard Stenzel <gerhard.stenzel@de.ibm.com>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Jens Osterkamp <jens@linux.vnet.ibm.com>,
        Patrick Mullaney <pmullaney@novell.com>,
        Stephen Hemminger <shemminger@vyatta.com>,
        David Miller <davem@davemloft.net>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1259251631-11617-1-git-send-email-arnd@arndb.de>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann wrote:
> Version 2 description:
> The patch to iproute2 has not changed, so I'm not including
> it this time. Patch 4/4 (the netlink interface) is basically
> unchanged as well but included for completeness.
> 
> The other changes have moved forward a bit, to the point where
> I find them a lot cleaner and am more confident in the code
> being ready for inclusion. The implementation hardly resembles
> Erics original patch now, so I've dropped his signed-off-by.
> 
> Please take a look and ack if you are happy so we can get it
> into 2.6.33.

Looks good to me, nice work.

Acked-by: Patrick McHardy <kaber@trash.net>

for the entire series.
