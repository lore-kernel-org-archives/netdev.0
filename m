From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH r8169] ethtool support and sane speed selection/detection
Date: Wed, 28 Apr 2004 17:51:35 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040428175135.A27651@electric-eye.fr.zoreil.com>
References: <20040424050931.14C341D4F@luto.stanford.edu> <408FA6B3.1000805@terra.com.br> <408FD2CB.6000102@myrealbox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Felipe W Damasio <felipewd@terra.com.br>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andy Lutomirski <luto@myrealbox.com>
Content-Disposition: inline
In-Reply-To: <408FD2CB.6000102@myrealbox.com>; from luto@myrealbox.com on Wed, Apr 28, 2004 at 08:50:35AM -0700
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andy Lutomirski <luto@myrealbox.com> :
[...]
> Francois, do you want a new patch, or should I wait until you finish 
> whatever you're doing?

I have already added some locks. Btw the timer should probably be protected
as well.

--
Ueimor
