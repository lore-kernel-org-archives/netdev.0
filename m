From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Subject: Re: about routing
Date: Mon, 7 Dec 2009 06:46:28 +1030
Message-ID: <20091207064628.5c217b0d@opy.nosense.org>
References: <f4f837ab0912060840k4aa73c5br8703e2294a642e4b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas yang <lampsu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.adam.net.au ([202.136.110.251]:41903 "EHLO
	smtp2.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757432AbZLFUQZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Dec 2009 15:16:25 -0500
In-Reply-To: <f4f837ab0912060840k4aa73c5br8703e2294a642e4b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 7 Dec 2009 00:40:25 +0800
thomas yang <lampsu@gmail.com> wrote:

> Hi,
> 
> I have a Linux router with 3 interfaces eth0, wlan0, wlan1 (their IP
> addresses 192.168.1.5/24,
> 192.168.2.5/24, 192.168.3.5/24).
> 
> I want to forward a packet (come in   from eth0,   its destination is
> another network)   through wlan0 and wlan1 at the
> same time,  then to different next hop.  Could you give me some ideas
> to implement this?
> 
> 

Multicast IP?


> --
> Thomas
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
