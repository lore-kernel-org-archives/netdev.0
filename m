From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Linux 3.6.x kernel crash in tcp_slow_start / bictcp_cong_avoid with wfica
Date: Thu, 24 Jan 2013 00:41:16 +0100
Message-ID: <20130123234116.GC16641@order.stressinduktion.org>
References: <20130123161238.GE8912@reaktio.net> <20130123214445.GA16641@order.stressinduktion.org> <20130123215151.GF8912@reaktio.net> <20130123152642.4a8389ba@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Pasi =?utf-8?B?S8Okcmtrw6RpbmVu?= <pasik@iki.fi>,
	netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:47412 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752622Ab3AWXlR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 18:41:17 -0500
Content-Disposition: inline
In-Reply-To: <20130123152642.4a8389ba@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 23, 2013 at 03:26:42PM -0800, Stephen Hemminger wrote:
> I see no problems when using Citrix.
> This is a normal strace of the program wifca (in idle loop)

Thanks, could you also have a look at setsockopts while socket creation and
connection establishment?
