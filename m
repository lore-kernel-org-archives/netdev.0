From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH PKT_SCHED 0/4]: more fixes
Date: Wed, 19 Jan 2005 12:47:08 +0100
Message-ID: <20050119114708.GX26856@postel.suug.ch>
References: <41EDE44E.9050609@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <41EDE44E.9050609@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Patrick McHardy <41EDE44E.9050609@trash.net> 2005-01-19 05:38
>  o [PKT_SCHED]: fix CONFIG_NET_CLS_ACT skb leaks in HFSC/CBQ
>  o [PKT_SCHED]: cls_route: fix tcf_exts fallout
>  o [PKT_SCHED]: cls_api.c: fix module reference leak on module load
>  o [PKT_SCHED]: cls_rsvp: fix tcf_exts fallout

Good catches. They all look good from here.
