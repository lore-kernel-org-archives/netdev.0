From: Simon Kirby <sim@netnation.com>
Subject: Re: Route cache performance
Date: Wed, 7 Sep 2005 09:57:58 -0700
Message-ID: <20050907165758.GD24735@netnation.com>
References: <20050824000158.GA8137@netnation.com> <20050825181111.GB14336@netnation.com> <20050825200543.GA6612@yakov.inr.ac.ru> <20050825212211.GA23384@netnation.com> <20050826115520.GA12351@yakov.inr.ac.ru> <17167.29239.469711.847951@robur.slu.se> <20050906235700.GA31820@netnation.com> <17182.64751.340488.996748@robur.slu.se> <20050907162854.GB24735@netnation.com> <17183.6655.977975.249491@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Eric Dumazet <dada1@cosmosbay.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Content-Disposition: inline
In-Reply-To: <17183.6655.977975.249491@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Sep 07, 2005 at 06:49:03PM +0200, Robert Olsson wrote:

>  It's called trade-off's :) rDoS is hardly nomal case? But maybe it's time 
>  to compare routing via route hash vs FIB lookup directly again now when 
>  we have RCU with some FIB lookup's too.

I haven't even filled the route tables yet.  I've just been testing with
a bog standard table (three /24s and one /0).

Simon-
