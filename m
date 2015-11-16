From: Patrick Schaaf <kernelorg@bof.de>
Subject: Re: Kernel 4.1 hang, apparently in __inet_lookup_established
Date: Mon, 16 Nov 2015 12:30:05 +0100
Message-ID: <2588265.diTR9b7D2W@rofl>
References: <5726932.6r4XOZ2Km2@rofl> <1443025879.29850.116.camel@edumazet-glaptop2.roam.corp.google.com> <56492A39.2060307@fastly.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	NETDEV <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Grant Zhang <gzhang@fastly.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56492A39.2060307@fastly.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 15 November 2015 16:58:33 Grant Zhang wrote:
> 
> Have you tried the two patches Eric mentioned? One of my 4.1.11 server
> just hanged with very similar stack trace and I am wondering whether the
> aforementioned patches would help.

Sorry, Grant - I'm sticking to 3.14.xx for now.

best regards
  Patrick
