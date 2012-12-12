From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH net-next v5] bridge: export multicast database
 via netlink
Date: Wed, 12 Dec 2012 15:59:21 +0800
Message-ID: <1355299161.2468.2.camel@cr0>
References: <1354874688-24564-1-git-send-email-amwang@redhat.com>
	<20121211164856.37ce94fe@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Jesper Dangaard Brouer <brouer@redhat.com>, Thomas Graf <tgraf@suug.ch>,
	"David S. Miller" <davem@davemloft.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20121211164856.37ce94fe@nehalam.linuxnetplumber.net>
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

On Tue, 2012-12-11 at 16:48 -0800, Stephen Hemminger wrote:    
> 
> Applied, but required some manual fixing. It required adding if_bridge.h
> to include/linux in iproute2 exported headers. Also patch still had some fuzz
> against current version.
> 

Thanks, Stephen!

I thought those headers are sync'ed with kernel headers automatically,
so we have to keep them up to date manually.
