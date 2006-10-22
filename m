From: Darren Salt <linux@youmustbejoking.demon.co.uk>
Subject: Re: [patch 1/1] r8169 driver: corega support
Date: Sun, 22 Oct 2006 16:14:41 +0100
Message-ID: <4E79DBAA03%linux@youmustbejoking.demon.co.uk>
References: <20061020224438.GA1794@electric-eye.fr.zoreil.com> <4E79505750%linux@youmustbejoking.demon.co.uk>
 <20061021201533.GA31768@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, hchacha@users.sourceforge.net, jeff@garzik.org,
	syed.azam@hp.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from anchor-post-31.mail.demon.net ([194.217.242.89]:54792 "EHLO
	anchor-post-31.mail.demon.net") by vger.kernel.org with ESMTP
	id S1750808AbWJVPRg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Oct 2006 11:17:36 -0400
To: romieu@fr.zoreil.com
In-Reply-To: <20061021201533.GA31768@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I demand that Francois Romieu may or may not have written...

> Darren Salt <linux@youmustbejoking.demon.co.uk> :
> [...]
>> It does, but the patch causes the module to report that the reset failed
>> even after reporting that it's done. A fix for this is attached.

> Oops. Ok with the one below?

Yes.

[snip patch]
-- 
| Darren Salt    | linux or ds at              | nr. Ashington, | Toon
| RISC OS, Linux | youmustbejoking,demon,co,uk | Northumberland | Army
| + Output less CO2 => avoid massive flooding.    TIME IS RUNNING OUT *FAST*.

Wagner's music is better than it sounds.
