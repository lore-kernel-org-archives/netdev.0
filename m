From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v4 iproute2] ip: Add color output option
Date: Mon, 4 May 2015 08:42:31 -0700
Message-ID: <20150504084231.21003f60@urahara>
References: <20150428101821.GA25794@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, aleksi.aalto@iki.fi
To: Mathias Nyman <m.nyman@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:36760 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751030AbbEDPm1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 11:42:27 -0400
Received: by pdea3 with SMTP id a3so166296353pde.3
        for <netdev@vger.kernel.org>; Mon, 04 May 2015 08:42:26 -0700 (PDT)
In-Reply-To: <20150428101821.GA25794@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 28 Apr 2015 13:18:21 +0300
Mathias Nyman <m.nyman@iki.fi> wrote:

> It is hard to quickly find what you are looking for in the output of the
> ip command. Color helps.
> 
> This patch adds a '-c' flag to highlight these with individual colors:
>   - interface name
>   - ip address
>   - mac address
>   - up/down state
> 
> Signed-off-by: Mathias Nyman <m.nyman@iki.fi>

Applied, thanks.
Maybe someone can do same thing to tc and ss.
