From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next] net: Remove unlikely() for WARN_ON()
 conditions
Date: Wed, 30 Jul 2014 17:42:06 -0700 (PDT)
Message-ID: <20140730.174206.1759327100199128334.davem@davemloft.net>
References: <3d85d9264cad5d116792e896149e41e5f14678ce.1406680126.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: tgraf-G/eBtMaohhA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <3d85d9264cad5d116792e896149e41e5f14678ce.1406680126.git.tgraf-G/eBtMaohhA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Date: Wed, 30 Jul 2014 02:31:08 +0200

> No need for the unlikely(), WARN_ON() and BUG_ON() internally use
> unlikely() on the condition.
> 
> Signed-off-by: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>

Applied, thanks.
