From: "David S. Miller" <davem@redhat.com>
Subject: Re: /proc/net/* read drops data
Date: Thu, 4 Sep 2003 00:46:38 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20030904004638.1d4b001d.davem@redhat.com>
References: <Pine.GSO.4.33.0308271658370.7750-100000@sweetums.bluetronic.net>
	<Pine.GSO.4.33.0308271935550.7750-100000@sweetums.bluetronic.net>
	<20030903.160733.06230402.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jfbeam@bluetronic.net, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: "YOSHIFUJI Hideaki / _$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
In-Reply-To: <20030903.160733.06230402.yoshfuji@linux-ipv6.org>
List-Id: netdev.vger.kernel.org

On Wed, 03 Sep 2003 16:07:33 +0900 (JST)
YOSHIFUJI Hideaki / _$B5HF#1QL@ <yoshfuji@linux-ipv6.org> wrote:

> D: Fixing a bug that reading /proc/net/{udp,udp6} may drop some data

This fix looks good to me.  Applied.
