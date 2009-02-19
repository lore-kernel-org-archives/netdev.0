From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: mac-redirect
Date: Thu, 19 Feb 2009 20:30:14 +0100
Message-ID: <499DB346.5030805@gmail.com>
References: <ab4346860902160549ld55576gbcd6316817f5f198@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Victoria Muntean <vikimun@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <ab4346860902160549ld55576gbcd6316817f5f198@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Victoria Muntean wrote, On 02/16/2009 02:49 PM:

> Which rule/module of iptable 1.4.3 can change dest mac of the packet ?
> (in PreRouting)

I guess you need to use ebtables dnat for this yet.


Cheers,
Jarek P.
