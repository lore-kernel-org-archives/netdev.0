From: kuznet@ms2.inr.ac.ru
Subject: Re: addrconf.c - possible bug
Date: Mon, 15 Apr 2002 23:34:33 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200204151934.XAA22076@sex.inr.ac.ru>
References: <20020415192248.GB3218@pasky.ji.cz>
Mime-Version: 1.0
Cc: pasky@xs26.net, pekkas@netcore.fi, jan.oravec@xs26.net, netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: xs26-dev@xs26.net
In-Reply-To: <20020415192248.GB3218@pasky.ji.cz> from "Petr Baudis" at Apr 15, 2 09:22:48 pm
List-Id: netdev.vger.kernel.org

Hello!

>   With 2.4.19-pre5, the problem still persist :(.


Nothing wonderful, nothing has been changed. :-)

>   If there's any more info needed, please just tell us, we'll try to help you
> as much as possible.

Well, when you see this, dump routing tables with

ip -6 route ls table all

And addresses too with

ip addr ls


Alexey
