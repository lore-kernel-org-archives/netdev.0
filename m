From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] batched tc to improve change throughput
Date: Mon, 17 Jan 2005 17:05:39 +0100
Message-ID: <20050117160539.GD26856@postel.suug.ch>
References: <20050117152312.GC26856@postel.suug.ch> <1105976711.1078.1.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, Stephen Hemminger <shemminger@osdl.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1105976711.1078.1.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1105976711.1078.1.camel@jzny.localdomain> 2005-01-17 10:45
> You dont like the -batch option to tc? ;->

No, because:

 - it duplicates logic
 - it doesn't allow any commenting
 - it doesn't get along with my more complicated ematch parsing
