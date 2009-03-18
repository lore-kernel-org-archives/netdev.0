From: Patrick McHardy <kaber@trash.net>
Subject: Re: [ANNOUNCE]: First release of nftables
Date: Wed, 18 Mar 2009 10:52:14 +0100
Message-ID: <49C0C44E.70702@trash.net>
References: <49C078B6.4020603@trash.net> <49C0B093.7000908@trash.net> <20090318092039.GA2511@squirrel.roonstrasse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	sofar@foo-projects.org
To: Max Kellermann <max@duempel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090318092039.GA2511@squirrel.roonstrasse.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Max Kellermann wrote:
> On 2009/03/18 09:28, Patrick McHardy <kaber@trash.net> wrote:
>   
>> The rule snippets under tests/ pretty much all use obsolete syntax,
>> so I'm attaching a test script (which doesn't make much sense, just
>> testing features) so people can get a feeling for the syntax.
>>     
>
> Interesting, that looks very much like ferm's syntax:
>
>  http://ferm.foo-projects.org/
>  http://ferm.foo-projects.org/download/examples/webserver.ferm
>  http://ferm.foo-projects.org/download/examples/dsl_router.ferm
>
> (ferm is a popular frontend for iptables, developed in 2000 by Auke
> Kok; I took over maintainership a few years ago)
>   

Indeed, it looks pretty similar :) The function things is also something
I wanted to add later on. Currently I'm looking for a nice syntax to
declare, define and modify sets outside of rules. I'll have a look at
your manual, maybe I can find something I like :)
