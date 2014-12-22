From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2] ip lib: Added shorter timestamp option
Date: Mon, 22 Dec 2014 20:37:42 +0200
Message-ID: <20141222183742.GA26427@angus-think.lan>
References: <1418285526-28859-1-git-send-email-vadim4j@gmail.com>
 <20141222101212.04877275@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:41580 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754563AbaLVSrt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2014 13:47:49 -0500
Received: by mail-la0-f48.google.com with SMTP id gf13so4348948lab.21
        for <netdev@vger.kernel.org>; Mon, 22 Dec 2014 10:47:47 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20141222101212.04877275@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 22, 2014 at 10:12:12AM -0800, Stephen Hemminger wrote:
> On Thu, 11 Dec 2014 10:12:06 +0200
> Vadim Kochan <vadim4j@gmail.com> wrote:
> 
> > From: Vadim Kochan <vadim4j@gmail.com>
> > 
> > Added another timestamp format to look like more logging info:
> > 
> > [Dec 01 01:46:20.675589] 2: enp0s25: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default
> >     link/ether 3c:97:0e:a3:86:2e brd ff:ff:ff:ff:ff:ff
> > 
> > Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> 
> I would suggest supporting RFC3339 which is a standard for timestamps instead.
> 
> [2014-22-12T01:46:20.1012] ...
OK, thanks, I will look on at.
