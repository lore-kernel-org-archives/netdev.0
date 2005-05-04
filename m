From: jamal <hadi@cyberus.ca>
Subject: Re: patch: Action repeat
Date: Wed, 04 May 2005 10:23:49 -0400
Message-ID: <1115216629.7906.4.camel@localhost.localdomain>
References: <20050430235809.GI577@postel.suug.ch>
	 <1115035838.8929.236.camel@localhost.localdomain>
	 <20050502150632.GM577@postel.suug.ch>
	 <1115207194.7665.109.camel@localhost.localdomain>
	 <20050504123157.GA18452@postel.suug.ch>
	 <1115211549.7665.140.camel@localhost.localdomain>
	 <20050504132822.GB18452@postel.suug.ch>
	 <1115213600.7665.166.camel@localhost.localdomain>
	 <20050504134815.GD18452@postel.suug.ch>
	 <1115214782.7665.184.camel@localhost.localdomain>
	 <20050504140540.GE18452@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev <netdev@oss.sgi.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050504140540.GE18452@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-04-05 at 16:05 +0200, Thomas Graf wrote:


>  Assuming we define global as everything and local
> as per device/(ingress|egress) then we definitely need to invoke
> a reset on the way over to egress. 

Agreed. So shall we stick then to just make it a global-only?

cheers,
jamal
