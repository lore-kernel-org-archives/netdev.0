From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] ipvs: remove extra __ip_vs_conn_put for incoming ICMP
Date: Thu, 19 May 2005 12:30:16 -0700 (PDT)
Message-ID: <20050519.123016.37533248.davem@davemloft.net>
References: <Pine.LNX.4.58.0505141037430.1568@u.domain.uli>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, wensong@linux-vs.org
Return-path: <netdev-bounce@oss.sgi.com>
To: ja@ssi.bg
In-Reply-To: <Pine.LNX.4.58.0505141037430.1568@u.domain.uli>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Julian Anastasov <ja@ssi.bg>
Date: Sat, 14 May 2005 10:57:26 +0300 (EEST)

> 	Remove extra __ip_vs_conn_put for incoming ICMP in direct routing
> mode. Mark de Vries reports that IPVS connections are not leaked anymore.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Applied to 2.6.x, thanks for the patch Julian.
