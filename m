From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: [patch 1/8]  irda/act200l-sir: replace 	schedule_timeout() with msleep()
Date: Wed, 1 Sep 2004 14:09:29 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040901210929.GA11442@bougret.hpl.hp.com>
References: <E1C2cIF-0007yy-Lb@sputnik>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: janitor@sternwelten.at
Content-Disposition: inline
In-Reply-To: <E1C2cIF-0007yy-Lb@sputnik>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Sep 01, 2004 at 11:05:23PM +0200, janitor@sternwelten.at wrote:
> 
> 
> 
> 
> 
> 
> I would appreciate any comments from the janitor@sternweltens list. 

	I already commented that I don't like the confusing msleep()
API and I prefer the more explicit schedule_timeout().
	But that's only me...

	Jean
