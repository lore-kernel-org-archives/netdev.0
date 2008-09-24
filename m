From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: read MAC address from EEPROM on init
Date: Wed, 24 Sep 2008 23:10:21 +0200
Message-ID: <20080924211021.GB9746@electric-eye.fr.zoreil.com>
References: <48D25BA2.6070008@redhat.com> <Pine.LNX.4.64.0809182235550.4742@wrl-59.cs.helsinki.fi> <48D3A381.1080500@redhat.com> <Pine.LNX.4.64.0809210100020.16838@wrl-59.cs.helsinki.fi> <48D9FE65.40709@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Netdev <netdev@vger.kernel.org>,
	Edward Hsu <edward_hsu@realtek.com.tw>
To: Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:54327 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752231AbYIXVKq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 17:10:46 -0400
Content-Disposition: inline
In-Reply-To: <48D9FE65.40709@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ivan Vecera <ivecera@redhat.com> :
[...]
> OK :-), I hope the patch below is finally the right one.

My approval ratings won't surge today.

Is there a specific explanation for the 10 us delay ?

Realtek's 8168 / 8169 / 8101 drivers all use a (wildly copy'pasted ?)
10 ms delay. I would not mind a 10 ms sleep.

-- 
Ueimor
