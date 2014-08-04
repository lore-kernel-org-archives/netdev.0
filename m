From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] bridge: remove a useless comment
Date: Mon, 4 Aug 2014 08:45:32 -0700
Message-ID: <20140804084532.6b84524c@haswell.linuxnetplumber.net>
References: <1407158554-17384-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1407158554-17384-1-git-send-email-mst@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Mon, 4 Aug 2014 15:22:40 +0200
"Michael S. Tsirkin" <mst@redhat.com> wrote:

> commit 6cbdceeb1cb12c7d620161925a8c3e81daadb2e4
>     bridge: Dump vlan information from a bridge port
> introduced a comment in an attempt to explain the
> code logic. The comment is unfinished so it confuses more
> than it explains, remove it.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Acked-by: Stephen Hemminger <stephen@networkplumber.org>
