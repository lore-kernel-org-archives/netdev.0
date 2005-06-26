From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: sis900 and fedora troubles
Date: Sun, 26 Jun 2005 10:50:50 +0200
Message-ID: <20050626085050.GA22215@electric-eye.fr.zoreil.com>
References: <1119667765.8496.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Damian <res0d26i@verizon.net>
Content-Disposition: inline
In-Reply-To: <1119667765.8496.6.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Damian <res0d26i@verizon.net> :
[...]
> I am so very sorry I can't give you more output, but the laptop is
> virtually connectionless. All I can tell you is that Ubuntu ran the card
> fine but Fedora for some reason doesn't. Any info is highly appreciated.

The exact revisions for both kernels are needed as a start. The complete
dmesg would be welcome as well (if it gets truncated, the missing bits
are probably stored in some distro-specific localtion, see /var/log for 
instance).

So far it is not even clear if it should be bugzilled in Fedora or in Ubuntu
(anyway, if changes can not be tested due to the lack of connection... :o/ ).

--
Ueimor
