From: "Nivedita Singhvi" <nivedita@us.ibm.com>
Subject: Re: making routes permanent
Date: Mon, 29 Apr 2002 13:52:49 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <OF717B3A86.1D7C5AC5-ON88256BAA.0071CA5F@boulder.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Glynn Clements <glynn.clements@virgin.net>,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Vinod <geekvinod@yahoo.com>
List-Id: netdev.vger.kernel.org




> i tried putting
> any net 10.0.3.0 255.255.255.0 gw 10.0.0.10
                  ^
                  |
Incidentally, you are missing the keyword netmask


> in my /etc/sysconfig/static-routes but still it didnt
> show up as a permanent route.i looked at the
> /etc/rc.d/inet.d/network script and as far as i could
> interpret(am a relative newbie),this was supposed to
> be the format for my RH 7.2.
> can anyone using rh7.2  confirm that "any net 10.0.3.0
> 255.255.255.0 gw 10.0.0.10" is what needs to be put in
> /etc/sysconfig/static-routes to make this entry
> permanent?
> Thanks,
> Vinod

thanks,
Nivedita



