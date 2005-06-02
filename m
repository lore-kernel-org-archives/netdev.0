From: jamal <hadi@cyberus.ca>
Subject: Re: PATCH: explicit typing WAS(Re: PATCH: rtnetlink explicit flags
	setting
Date: Thu, 02 Jun 2005 09:30:32 -0400
Message-ID: <1117719032.6050.50.camel@localhost.localdomain>
References: <1117197157.6688.24.camel@localhost.localdomain>
	 <20050531.144338.112623594.davem@davemloft.net>
	 <20050531222646.GK15391@postel.suug.ch>
	 <20050531.153125.95894437.davem@davemloft.net>
	 <1117717493.6050.29.camel@localhost.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <1117717493.6050.29.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I should say this patch is against net-2.6.13.git as of 6am this
morning.

cheers,
jamal

On Thu, 2005-02-06 at 09:04 -0400, jamal wrote:

> -------------
> This patch converts "unsigned flags" to use more explict types like u16
> instead and incrementally introduces NLMSG_NEW().
>  
> Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca> 
> 
