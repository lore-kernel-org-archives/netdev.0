From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Realtek 8111C transmit timed out
Date: Mon, 25 Aug 2008 00:09:42 +0200
Message-ID: <20080824220942.GA6059@electric-eye.fr.zoreil.com>
References: <2c2a4e250808041812j569f6565s9f4ae54f44bbfbb5@mail.gmail.com> <2c2a4e250808041900id64a2b8h1b7cee3b70960ebc@mail.gmail.com> <2c2a4e250808042042j6c448068v98a6b5e428fa1a7@mail.gmail.com> <20080805214250.GA23226@electric-eye.fr.zoreil.com> <2c2a4e250808052221p7d22adf5w7a656e423bff0b26@mail.gmail.com> <20080806190353.GB17174@electric-eye.fr.zoreil.com> <2c2a4e250808062251p74f97863l770727843921a5c4@mail.gmail.com> <20080807223137.GA17407@electric-eye.fr.zoreil.com> <2c2a4e250808072028h8b7a13av29ec02f76ab08cd1@mail.gmail.com> <2c2a4e250808221255l6803e0d9q1021626a616d7ffc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: John P Poet <jppoet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:47256 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750909AbYHXWJr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Aug 2008 18:09:47 -0400
Content-Disposition: inline
In-Reply-To: <2c2a4e250808221255l6803e0d9q1021626a616d7ffc@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John P Poet <jppoet@gmail.com> :
[...]
> Should I try the "official" driver from Realtek ?

Yes, it would be interesting to know if it performs better.

Could you send the output of 'mii-tool -vv' ? I am curious to know how
to identify your PHY.

> How hard is it to integrate ?

It is supposed to build as an external module.

-- 
Ueimor
