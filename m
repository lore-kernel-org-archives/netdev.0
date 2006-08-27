From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: RTL8136
Date: Sun, 27 Aug 2006 23:41:35 +0200
Message-ID: <20060827214135.GA21464@electric-eye.fr.zoreil.com>
References: <4E5C083B8E%linux@youmustbejoking.demon.co.uk> <20060825190455.GA14812@electric-eye.fr.zoreil.com> <4E5C6C7764%linux@youmustbejoking.demon.co.uk> <4E5CF8AF74%linux@youmustbejoking.demon.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:2458 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S932267AbWH0Vnf
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Aug 2006 17:43:35 -0400
To: Darren Salt <linux@youmustbejoking.demon.co.uk>
Content-Disposition: inline
In-Reply-To: <4E5CF8AF74%linux@youmustbejoking.demon.co.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Darren Salt <linux@youmustbejoking.demon.co.uk> :
[...]
> Whoops. I'd not noticed the -rc4 patches...
> 
> These seem to help a little: mii-tool can reset it and bring the link up
> regardless of RTL_CFG_{1,2}. After that, RTL_CFG_1 allows sending to work,
> and RTL_CFG_2 allows both sending and receiving to work (tested by trying to
> get an IP address via DHCP).

Did you need to play with mii-tool to have DHCP working or did it work
automagically (assuming the -rc4 patches + the RTL_CFG_2 change of course) ?

-- 
Ueimor
