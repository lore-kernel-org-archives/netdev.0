From: Ricky Beam <jfbeam@bluetronic.net>
Subject: Re: /proc/net/* read drops data
Date: Thu, 4 Sep 2003 12:21:00 -0400 (EDT)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <Pine.GSO.4.33.0309041220070.13584-100000@sweetums.bluetronic.net>
References: <20030904004638.1d4b001d.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "YOSHIFUJI Hideaki / _$B5HF#1QL@" <yoshfuji@linux-ipv6.org>,
	<linux-kernel@vger.kernel.org>, <netdev@oss.sgi.com>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030904004638.1d4b001d.davem@redhat.com>
List-Id: netdev.vger.kernel.org

On Thu, 4 Sep 2003, David S. Miller wrote:
>> D: Fixing a bug that reading /proc/net/{udp,udp6} may drop some data
>
>This fix looks good to me.  Applied.

That might fix udp, but that's not the only one to be fixed.  I'll compile
a list. (tcp for sure.)

--Ricky
