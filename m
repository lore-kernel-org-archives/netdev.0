From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Thu, 12 Jun 2003 23:21:14 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030612.232114.71088346.davem@redhat.com>
References: <004f01c32ebe$b4bd88d0$4a00000a@badass>
	<20030609221911.GF11509@netnation.com>
	<16101.4136.328760.955758@robur.slu.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sim@netnation.com, xerox@foonet.net, hadi@shell.cyberus.ca,
	fw@deneb.enyo.de, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Robert.Olsson@data.slu.se
In-Reply-To: <16101.4136.328760.955758@robur.slu.se>
List-Id: netdev.vger.kernel.org

   From: Robert Olsson <Robert.Olsson@data.slu.se>
   Date: Tue, 10 Jun 2003 00:54:32 +0200
    
    I'm about to propose some stats even for hash spinning.... 

Do you mind if I apply this?  It looks fine.

Next, we should put similar metrics into fib_hash.c
