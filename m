From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 0/4]: more fixes
Date: Wed, 19 Jan 2005 05:38:38 +0100
Message-ID: <41EDE44E.9050609@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Dave,

following are a couple assorted fixes for some bugs recently introduced.
You can pull all changes from bk://212.42.230.204/net-2.6-sched

Regards
Patrick


Patrick McHardy:
  o Merge coreworks.de:/home/kaber/src/bk-repos/net-2.6 into 
coreworks.de:/home/kaber/src/net/net-2.6-sched
  o [PKT_SCHED]: fix CONFIG_NET_CLS_ACT skb leaks in HFSC/CBQ
  o [PKT_SCHED]: cls_route: fix tcf_exts fallout
  o [PKT_SCHED]: cls_api.c: fix module reference leak on module load
  o [PKT_SCHED]: cls_rsvp: fix tcf_exts fallout
