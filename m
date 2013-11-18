From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: bridge: flush br's address entry in fdb when remove
 the bridge dev
Date: Mon, 18 Nov 2013 16:34:19 +0800
Message-ID: <5289D10B.9080501@huawei.com>
References: <5289CEFE.607@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Stephen Hemminger <stephen@networkplumber.org>, "David S. Miller"
	<davem@davemloft.net>, <bridge@lists.linux-foundation.org>, Netdev
	<netdev@vger.kernel.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <5289CEFE.607@huawei.com>
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

On 2013/11/18 16:25, Ding Tianhong wrote:
> When the following commands are executed:
> 
> brctl addbr br0
> ifconfig br0 hw ether <addr>
> rmmod bridge
> 
> The calltrace will occur:

wrong title, miss it, please.
