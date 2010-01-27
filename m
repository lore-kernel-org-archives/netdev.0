From: Curt Sampson <cjs@starling-software.com>
Subject: Re: Problems Receiving UDP Broadcasts on Some Versions of Linux
Date: Wed, 27 Jan 2010 09:37:46 +0900
Message-ID: <20100127003744.GA16322@analytic.cynic.net>
References: <20100125072749.GG21419@analytic.cynic.net> <4B5D51E6.5090601@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754221Ab0A0Ahz@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B5D51E6.5090601@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2010-01-25 09:10 +0100 (Mon), Eric Dumazet wrote:

> > The short summary is that on two very similar servers on the same
> > network, an application that listens for broadcast UDP packets on a
> > given port works fine on the Ubuntu 8.04/Linux 2.6.24-26-server box but
> > does not receive the packets on the Ubuntu 9.04/Linux 2.6.28-17-server
> > box.
>
> Could you post a sample of tcpdump trafic you receive on the 9.04
> host, and your network config ? "ifconfig -a"

I've added both to the end of the StackOverflow entry:

  http://stackoverflow.com/questions/2130563/udp-broadcast-reception-problems-with-ubuntu-9-04-but-not-8-04

Again, please cc me on any responses; I'm on neither the linux-kernel
nor netdev lists.

cjs
-- 
Curt Sampson         <cjs@cynic.net>         +81 90 7737 2974
             http://www.starling-software.com
The power of accurate observation is commonly called cynicism
by those who have not got it.    --George Bernard Shaw
