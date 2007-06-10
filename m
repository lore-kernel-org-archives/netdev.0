From: linux-wireless-5/S+JYg5SzeELgA04lAiVw@public.gmane.org
Subject: Re: The future of the TI ACX wireless driver
Date: Sun, 10 Jun 2007 19:06:28 +0200
Message-ID: <466C2F94.8050501@hauke-m.de>
References: <1d9d9b240706100735k374b5800ie64370e1e9bff1ef@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: acx100-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Planella <david.planella-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1d9d9b240706100735k374b5800ie64370e1e9bff1ef-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hi

Nice work David.

I have extracted the acxsm driver out of the wireless-2.6 git tree and
made it compile on at least kernel 2.6.20 and 2.6.22-rc4
It can be found here:
http://www.hauke-m.de/fileadmin/acx/tiacx-20070522.tar.bz2

I also chanced some lines in the normal acx driver so it compiles with
kenrel 2.6.22 and later
http://www.hauke-m.de/fileadmin/acx/acx-20070610.tar.bz2

Bouth are loading on my system, but I can't test them because I haven't
got any acx100 chip based card any more, it would be nice to get
positive feedback, when it's working.

I will write some pages into the Wiki for these versions, so everyone
can test them.

I am not a big kernel hacker but I want to learn it too.

Hauke Mehrtens
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFGbC+UrcX0gpXFjnsRAiZvAJ9HqeLhYD71ziIY8nn1/s165IgW9wCeOkta
jcvdcupbincXF0WpXVQse5s=
=1Dty
-----END PGP SIGNATURE-----
