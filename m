From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: avoid unnecessary read of
	jiffies
Date: Tue, 07 Feb 2017 14:16:30 -0500 (EST)
Message-ID: <20170207.141630.1294831074568265709.davem@davemloft.net>
References: <1486227909-18319-1-git-send-email-nikolay@cumulusnetworks.com>
	<1486227909-18319-5-git-send-email-nikolay@cumulusnetworks.com>
	<20170207084646.70dc888a@xeon-e3>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nikolay@cumulusnetworks.com, netdev@vger.kernel.org,
	roopa@cumulusnetworks.com, bridge@lists.linux-foundation.org
To: stephen@networkplumber.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20170207084646.70dc888a@xeon-e3>
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

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Tue, 7 Feb 2017 08:46:46 -0800

> Jiffies is volatile so read it once.
> 
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>

Applied, thanks Stephen.
