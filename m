From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/9] PKT_SCHED: tc filter extension API
Date: 31 Dec 2004 00:04:39 -0500
Message-ID: <1104469479.1047.227.camel@jzny.localdomain>
References: <20041230122652.GM32419@postel.suug.ch>
	 <20041230123023.GO32419@postel.suug.ch> <41D4A4D2.4000109@trash.net>
	 <41D4B3AD.9080605@conectiva.com.br>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, Thomas Graf <tgraf@suug.ch>,
        "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <41D4B3AD.9080605@conectiva.com.br>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-12-30 at 21:04, Arnaldo Carvalho de Melo wrote:

> > 
> > Please use act == NULL
> 
> Agreed, but I understand the people who like this (ugly) style, it becomes
> less likely to become an "if (act = NULL)", but hey, compilers already
> helps us with a nice warning.

There are certain people who would kill you for doing the above ;->
Or maybe theyll just take away your coffee. I think its a taste issue.
Code looks fine either way. 

cheers,
jamal
