From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH] network configs: disconnect network options from drivers
Date: Mon, 4 Apr 2005 23:55:54 +0200
Message-ID: <20050404215554.GA29170@mars.ravnborg.org>
References: <20050330234709.1868eee5.randy.dunlap@verizon.net> <20050331185226.GA8146@mars.ravnborg.org> <424C5745.7020501@osdl.org> <20050331203010.GA8034@mars.ravnborg.org> <4250B4C5.2000200@osdl.org> <20050404195051.GA12364@mars.ravnborg.org> <4251A830.5030905@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ioe-lkml@axxeo.de, matthew@wil.cx, lkml <linux-kernel@vger.kernel.org>,
        netdev@oss.sgi.com, hadi@cyberus.ca, cfriesen@nortel.com,
        tgraf@suug.ch
Return-path: <netdev-bounce@oss.sgi.com>
To: "Randy.Dunlap" <rddunlap@osdl.org>
Content-Disposition: inline
In-Reply-To: <4251A830.5030905@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 
> >- Move submenu to the top
> >- Rename top menu to "Networking" and located it just before
> > "File systems"
> 
> I still prefer Networking to come before Device Drivers FWIW.
> Just makes some kind of hierarchical sense to me.
Moved up as suggested.

> I propose that the new file net/atm/Kconfig be sourced somewhere.
Thanks, I have missed that one - added just before wanrouter.
 
> I'll look at it more to see if I have any other comments.
OK. I will await and post an updated patch if you do not beat me.

	Sam
