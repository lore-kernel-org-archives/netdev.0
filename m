From: jamal <hadi@cyberus.ca>
Subject: Re: unregister_netdev Annoyance WAS(Re: ing_filter debug messages
Date: 03 Jan 2005 09:50:40 -0500
Message-ID: <1104763839.1047.563.camel@jzny.localdomain>
References: <20041230160643.GD24603@wiggy.net>
	 <1104469666.1049.231.camel@jzny.localdomain>
	 <20041231093827.GG24603@wiggy.net>
	 <1104491510.1047.234.camel@jzny.localdomain>
	 <20041231131553.GA7460@wiggy.net>
	 <1104505838.1048.273.camel@jzny.localdomain>
	 <20041231154844.GA11511@wiggy.net>
	 <1104511697.1048.308.camel@jzny.localdomain>
	 <20050102121349.GA27022@outpost.ds9a.nl>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Wichert Akkerman <wichert@wiggy.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: bert hubert <ahu@ds9a.nl>
In-Reply-To: <20050102121349.GA27022@outpost.ds9a.nl>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2005-01-02 at 07:13, bert hubert wrote:

> This is a separate and known problem - see 'Re: Major deadlock:
> unregister_netdevice: waiting for <device> to become free. Usage count = 1'
> by Peter Bieringer.
> 
> For some reason this issue has been widely ignored. I see it as well here
> and it is the one reason I don't entirely trust 2.6.10 yet in production.
> 
> Thanks for looking into it Jamal!

This issue was already being looked into by about 3 people {Dave,
Yoshfuji-san, Herbert}. They have more knowledge about the circumstances
than i do. The holidays are over, so give it a short time and lets see
what happens.

cheers,
jamal
