From: Maciej Soltysiak <solt@dns.toxicfilms.tv>
Subject: Re: IP-ID field of ICMP echo request
Date: Mon, 7 Jul 2003 14:48:41 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.51.0307071443080.3379@dns.toxicfilms.tv>
References: <3F095B7B.5090203@cysols.com> <Pine.LNX.4.51.0307071420020.2129@dns.toxicfilms.tv>
 <20030707.213930.07095787.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kohei@cysols.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20030707.213930.07095787.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> No, he is not talking about ICMP Identifier (RFC792 Page 14),
> but IP Identification (RFC791 Page 29).
Aah, yes, I misread. Sorry.

Anyway I tested it on 2.4.2 and 2.4.18, 2.5.74 and 2.4.21, they set IP ID
to 0. At first I thought it was that issue with early 2.4, but it seems it
has been there for a while.

> --yoshfuji
Maciej
