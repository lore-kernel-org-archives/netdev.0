From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: kernel BUG at kernel/timer.c:951!
Date: Sat, 19 Dec 2009 18:40:53 +0100
Message-ID: <4B2D1025.1020106@gmail.com>
References: <4B2CD772.1030106@upmc.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Bernard Pidoux <bpidoux@free.fr>
To: Bernard Pidoux <bernard.pidoux@upmc.fr>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753214AbZLSRlZ@vger.kernel.org>
In-Reply-To: <4B2CD772.1030106@upmc.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bernard Pidoux wrote, On 12/19/2009 02:38 PM:

> I am experiencing a few kernel panics on my Linux system using 2.6.32 and 2.6.32.1 kernels
> with nosmp. 

Some of these oopses look similarly to those:
http://markmail.org/message/scjov36zm2wf2ytv

How about this patch I sent you for testing?:
http://markmail.org/message/nymi7xyd5c43hyfu

Jarek P.
