From: Henrik Nordstrom <hno@marasystems.com>
Subject: Re: Announce: NetKeeper Firewall For Linux
Date: Mon, 10 Nov 2003 16:12:04 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0311101610270.3272-100000@filer.marasystems.com>
References: <3FAE9B9B.60007@cs.auc.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: hadi@cyberus.ca, Emmanuel Fleury <fleury@cs.auc.dk>,
        "David S. Miller" <davem@redhat.com>,
        <netfilter-devel@lists.netfilter.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Mikkel Christiansen <mixxel@cs.auc.dk>
In-Reply-To: <3FAE9B9B.60007@cs.auc.dk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 9 Nov 2003, Mikkel Christiansen wrote:

> uploading. We believe this is a good thing since it allows
> admins to (syntax) check the filter before inserting it.
> I believe the guys from shorewall sees this as a missing
> feature of iptables.

See iptables-restore. It is exacly this (compile whole ruleset before
insert) for iptables. The only thing missing is that it only compiles one
table at a time.

Regards
Henrik
