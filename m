From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [patch v3, iproute2 version 3.2.0] Source mode for macvlan
 interface
Date: Mon, 30 Jan 2012 08:40:03 -0800
Message-ID: <20120130084003.50bcd3f2@nehalam.linuxnetplumber.net>
References: <10839102.1251327929240954.JavaMail.root@5-MeO-DMT.ynet.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stefan Gula <steweg@ynet.sk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34423 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753744Ab2A3QkG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jan 2012 11:40:06 -0500
In-Reply-To: <10839102.1251327929240954.JavaMail.root@5-MeO-DMT.ynet.sk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 30 Jan 2012 14:14:00 +0100 (CET)
Stefan Gula <steweg@ynet.sk> wrote:

> From: Stefan Gula <steweg@gmail.com>
> 
> Adjusting iproute2 utility to support new macvlan link type mode
> called "source". Example of commands that can be applied:
>  ip link add link eth0 name macvlan0 type macvlan mode source
>  ip link set link macvlan0 type macvlan macaddr add 00:11:11:11:11:11
>  ip link set link macvlan0 type macvlan macaddr del 00:11:11:11:11:11
>  ip link set link macvlan0 type macvlan macaddr flush
> 
> Signed-off-by: Stefan Gula <steweg@gmail.com>
> 

Documentation update?
