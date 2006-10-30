From: Jiri Benc <jbenc@suse.cz>
Subject: Re: Lost packets after switching Wi-Fi AP
Date: Mon, 30 Oct 2006 21:19:23 +0100
Message-ID: <20061030211923.79292f8d@griffin.suse.cz>
References: <4546127D.10403@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:18158 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S932466AbWJ3UTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2006 15:19:25 -0500
To: Benjamin Thery <benjamin.thery@bull.net>
In-Reply-To: <4546127D.10403@bull.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 30 Oct 2006 15:55:57 +0100, Benjamin Thery wrote:
> When I switch my Mobile Node between 2 Wi-Fi Access Points, there is a 
> period of time where all the packets I send are lost, although I got 
> the netlink event SIOCGIWAP 'up' for the new AP. The device is 
> supposed to be ready, but the packets are lost.

Which wireless card are you using? Which version of the kernel?

 Jiri

-- 
Jiri Benc
SUSE Labs
