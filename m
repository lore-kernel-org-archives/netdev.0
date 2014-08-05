From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: Update outdated comment on
 promiscuous mode
Date: Tue, 05 Aug 2014 16:37:32 -0700 (PDT)
Message-ID: <20140805.163732.670307887248646429.davem@davemloft.net>
References: <1407221835-15529-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, vyasevic@redhat.com,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: makita.toshiaki@lab.ntt.co.jp
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1407221835-15529-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
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

From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Date: Tue,  5 Aug 2014 15:57:15 +0900

> Now bridge ports can be non-promiscuous, vlan_vid_add() is no longer an
> unnecessary operation.
> 
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>

Applied.
