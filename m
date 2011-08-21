From: Michael Brade <brade@informatik.uni-muenchen.de>
Subject: Re: r8169 hard-freezes the system on big network loads
Date: Sun, 21 Aug 2011 15:20:50 +0200
Message-ID: <201108211520.50400.brade@informatik.uni-muenchen.de>
References: <201108141308.28140.kjun-chen@sambodha.org> <20110821123311.GA20605@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acheron.ifi.lmu.de ([129.187.214.135]:38015 "EHLO
	acheron.ifi.lmu.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752496Ab1HUNrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Aug 2011 09:47:46 -0400
In-Reply-To: <20110821123311.GA20605@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 21 August 2011 14:33:11 you wrote:
> (Michael, please don't use the e-mail address of your Solar meditation
> teacher)

Gee...?! that was an accident (and I thought I know what I am doing...)

> > If you need any other information or help, please let me know.
> 
> The XID line included in any recent kernel dmesg by the r8169 driver would
> be welcome.

r8169 0000:13:00.0: eth0: RTL8168d/8111d at 0xffffc90000c72000, 
f0:4d:a2:b8:ce:62, XID 083000c0 IRQ 52

hope that helps,
   Michael
