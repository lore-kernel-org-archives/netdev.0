From: jamal <hadi@cyberus.ca>
Subject: Re: patch: Action repeat
Date: Thu, 05 May 2005 09:06:39 -0400
Message-ID: <1115298399.7680.68.camel@localhost.localdomain>
References: <20050502150632.GM577@postel.suug.ch>
	 <1115207194.7665.109.camel@localhost.localdomain>
	 <20050504123157.GA18452@postel.suug.ch>
	 <1115211549.7665.140.camel@localhost.localdomain>
	 <20050504132822.GB18452@postel.suug.ch>
	 <1115213600.7665.166.camel@localhost.localdomain>
	 <20050504134815.GD18452@postel.suug.ch>
	 <1115214782.7665.184.camel@localhost.localdomain>
	 <20050504140540.GE18452@postel.suug.ch>
	 <1115216629.7906.4.camel@localhost.localdomain>
	 <20050504145341.GG18452@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev <netdev@oss.sgi.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050504145341.GG18452@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-04-05 at 16:53 +0200, Thomas Graf wrote:
> * jamal <1115216629.7906.4.camel@localhost.localdomain> 2005-05-04 10:23

> > Agreed. So shall we stick then to just make it a global-only?
> 
> As long as we can't find a way to have a well defined local
> scope which is both easy to implement and easy to understand
> for the user a global-only scope with the ability for the user
> to reset the value via the meta action is most reasonable to me.

ok - i will wait to see the patches from Patrick out first then do this.
Its actually a simple change.

cheers,
jamal
