From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] [SCHED] Fix unlock spinlock in error path
Date: Mon, 16 May 2005 22:12:33 +0200
Message-ID: <20050516201233.GE13748@postel.suug.ch>
References: <Pine.LNX.4.62.0505161555080.13294@webhosting.rdsbv.ro> <20050516134900.GC13748@postel.suug.ch> <Pine.LNX.4.62.0505162224420.20204@webhosting.rdsbv.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.62.0505162224420.20204@webhosting.rdsbv.ro>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Catalin(ux aka Dino) BOIE <Pine.LNX.4.62.0505162224420.20204@webhosting.rdsbv.ro> 2005-05-16 22:25
> Thanks Thomas for the explication!
> Sorry for the noise.

Don't worry, I should have documented this weird code part. ;->
