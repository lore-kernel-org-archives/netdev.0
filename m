From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: RTL8169 driver no longer functioning with 8111b
Date: Tue, 20 May 2008 23:08:22 +0200
Message-ID: <20080520210822.GB29349@electric-eye.fr.zoreil.com>
References: <4828D529.3060201@gtf.org> <20080513205140.GA11808@electric-eye.fr.zoreil.com> <Pine.LNX.4.64.0805131821500.2988@havoc.gtf.org> <20080514213710.GA8465@electric-eye.fr.zoreil.com> <482E19BD.3080208@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: ackman <ackman@gtf.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:36101 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757710AbYETVcR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 17:32:17 -0400
Content-Disposition: inline
In-Reply-To: <482E19BD.3080208@gtf.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ackman <ackman@gtf.org> :
[...]
> I could load the kernel r8169 driver back in again later if you need me to.

Please do. It gives a specific footprint of the device (the 'XID' line)
whereas Realtek's driver does not tell exactly which kind of 8168b was
detected.

-- 
Ueimor
