From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 7/6] cls_fw: CONFIG_NET_CLS_IND is not dependant on CONFIG_NET_CLS_ACT
Date: Fri, 29 Oct 2004 16:24:11 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041029142411.GT12289@postel.suug.ch>
References: <20041029002113.GY12289@postel.suug.ch> <20041029102620.GH12289@postel.suug.ch> <1099049980.1024.21.camel@jzny.localdomain> <20041029115333.GK12289@postel.suug.ch> <1099053306.1025.95.camel@jzny.localdomain> <20041029125356.GM12289@postel.suug.ch> <1099055561.1028.133.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1099055561.1028.133.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> no need for backward compat here. We have an opportunity since its not
> widely deployed. I wont feel sorry for any apps that somehow depend on
> old stats.

My thoughts as well.

> PS:- iproute2 patch needed.

Should be straight forward if my last patch made it in. Stephen?

> PPS:- I hope all the actions i queued to Dave are in ;->

So far gact, mirred and pedit, any more I need to take care of?
