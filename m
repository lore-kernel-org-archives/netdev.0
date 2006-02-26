From: John Zielinski <john_ml@undead.cc>
Subject: Re: VIA Velocity massive memory corruption with jumbo frames
Date: Sat, 25 Feb 2006 22:56:20 -0500
Message-ID: <440126E4.1030909@undead.cc>
References: <43FFFB6B.7090700@undead.cc> <20060225235346.GA18558@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751197AbWBZD41@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20060225235346.GA18558@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Try the patch below and Cc: netdev@vger.kernel.org on further messages
> please.
>   
It worked.  No more memory corruption and I can ping 9000 byte packets 
to my Windows box.
