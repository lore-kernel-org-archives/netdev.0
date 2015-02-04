From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: core/dev: fix sparse warning
Date: Wed, 04 Feb 2015 05:21:42 -0800
Message-ID: <1423056102.907.126.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1423052746-3688-1-git-send-email-prabhakar.csengg@gmail.com>
	 <1423053695.907.117.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+V-a8vSfY79pqOoSr=F-Am8g4jmhM_DfC2f-SNaiNt9qu7hEA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:58121 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932630AbbBDNVo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 08:21:44 -0500
In-Reply-To: <CA+V-a8vSfY79pqOoSr=F-Am8g4jmhM_DfC2f-SNaiNt9qu7hEA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-02-04 at 12:50 +0000, Lad, Prabhakar wrote:

> I tried it on gcc 4.3.3 and sparse with 0.4.5-rc1 version.

gcc-4.3.3 is 6 years old...
