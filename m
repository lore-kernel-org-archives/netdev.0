From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] batched tc to improve change throughput
Date: 17 Jan 2005 11:36:47 -0500
Message-ID: <1105979807.1078.16.camel@jzny.localdomain>
References: <20050117152312.GC26856@postel.suug.ch>
	 <1105976711.1078.1.camel@jzny.localdomain>
	 <20050117160539.GD26856@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, Stephen Hemminger <shemminger@osdl.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050117160539.GD26856@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-01-17 at 11:05, Thomas Graf wrote:
> * jamal <1105976711.1078.1.camel@jzny.localdomain> 2005-01-17 10:45
> > You dont like the -batch option to tc? ;->
> 
> No, because:
> 
>  - it duplicates logic

Didnt follow this - uses the same code as command line. What logic gets
duplicated?

>  - it doesn't allow any commenting

Trivial thing you can fix in about 33.5 seconds ;->

>  - it doesn't get along with my more complicated ematch parsing

Example?

cheers,
jamal
