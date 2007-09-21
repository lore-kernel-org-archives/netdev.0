From: Denys Vlasenko <vda.linux@googlemail.com>
Subject: Re: [PATCH 1/2] bnx2: factor out gzip unpacker
Date: Fri, 21 Sep 2007 19:05:23 +0100
Message-ID: <200709211905.23946.vda.linux@googlemail.com>
References: <200709211201.24475.vda.linux@googlemail.com> <200709211803.55554.vda.linux@googlemail.com> <20070921.104912.41646795.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, mchan@broadcom.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761460AbXIUSFp@vger.kernel.org>
In-Reply-To: <20070921.104912.41646795.davem@davemloft.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 21 September 2007 18:49, David Miller wrote:
> From: Denys Vlasenko <vda.linux@googlemail.com>
> Date: Fri, 21 Sep 2007 18:03:55 +0100
> 
> > Do patches look ok to you?
> 
> I'm travelling so I haven't looked closely yet :-)
> 
> Michael can take a look and I'll try to do so as well
> tonight.

Good.

I plan to use gzip compression on following drivers' firmware,
if patches will be accepted:

   text    data     bss     dec     hex filename
  17653  109968     240  127861   1f375 drivers/net/acenic.o
   6628  120448       4  127080   1f068 drivers/net/dgrs.o
         ^^^^^^

--
vda
