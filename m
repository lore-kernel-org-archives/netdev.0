From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] ip link/addr show: add empty line between interfaces
Date: Mon, 7 Sep 2015 11:09:32 -0700
Message-ID: <20150907110932.7687a913@urahara>
References: <1441537269-13899-1-git-send-email-felix.kaiser@fxkr.net>
	<20150907144609.3ec9f4d0@griffin>
	<1441639971-sup-8473@zero>
	<20150907175411.491f9c96@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Felix Kaiser <felix.kaiser@fxkr.net>, netdev@vger.kernel.org
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35911 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750936AbbIGSJW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2015 14:09:22 -0400
Received: by padhk3 with SMTP id hk3so17166173pad.3
        for <netdev@vger.kernel.org>; Mon, 07 Sep 2015 11:09:22 -0700 (PDT)
In-Reply-To: <20150907175411.491f9c96@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 7 Sep 2015 17:54:11 +0200
Jiri Benc <jbenc@redhat.com> wrote:

> On Mon, 07 Sep 2015 17:38:48 +0200, Felix Kaiser wrote:
> > My opinion is that if someone parses that, they deserve the opportunity
> > to fix their code. At the very least they could have used -oneline!
> 
> No doubt. I also don't like scripts that parse the default "ip a"
> output.
> 
> I just pointed out that there are different opinions and that it can
> have some consequences. Personally, I have no strong feeling against
> nor for the patch. It's up to Stephen to decide.
> 
> > I've met users who use a shell alias to hack newlines in
> 
> Which is not a bad solution, actually.
> 
>  Jiri
> 

Agreed with Jiri. I prefer the new shorter brief format, not longer format.
Did you ever try a system with 10 interfaces or 1000 tunnels??
