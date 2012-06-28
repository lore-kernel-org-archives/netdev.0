From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: 3.4.x regression: rtl8169: frequent resets
Date: Thu, 28 Jun 2012 21:30:26 +0200
Message-ID: <20120628193026.GA31627@electric-eye.fr.zoreil.com>
References: <87y5n7qup0.fsf@spindle.srvr.nix>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nix <nix@esperi.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87y5n7qup0.fsf@spindle.srvr.nix>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nix <nix@esperi.org.uk> :
> I recently upgraded from 3.3.x to 3.4.4, and am now experiencing
> networking problems with my desktop box's r8169 card. The symptoms are
> that all traffic ceases for five to ten seconds, then the card appears
> to reset and everything is back to normal -- until it happens again. It
> can happen quite a lot:

Can you try and revert 036dafa28da1e2565a8529de2ae663c37b7a0060 ?

I would welcome a complete dmesg including the XID line from the
r8169 driver.

Thanks.

-- 
Ueimor
