From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] ematch API, u32 ematch, nbyte ematch, basic classifier
Date: Wed, 5 Jan 2005 12:09:17 +0100
Message-ID: <20050105110917.GP26856@postel.suug.ch>
References: <20050103125635.GB26856@postel.suug.ch> <1104812028.1085.50.camel@jzny.localdomain> <20050104122738.GG26856@postel.suug.ch> <1104844935.1085.103.camel@jzny.localdomain> <20050104134126.GJ26856@postel.suug.ch> <1104893694.1124.37.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1104893694.1124.37.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1104893694.1124.37.camel@jzny.localdomain> 2005-01-04 21:54
> I think this is a debate that can be easily settled ;->
> Agreed logic will beat brute force smartness and u32 is not exactly
> for the faint hearted. And its usability is extremely poor - but lets
> maintain its power as is.

Absolutely.

> > Using what key? We have no knowledge about what the ematches want to
> > see or not.
> 
> Ok, good question ;->
> Maybe you should have own some 32 bit key?

Actually the goal of basic is to be an alternative to u32
if hashing is not required because I think adding hashing
will simply result in a duplication of u32.
