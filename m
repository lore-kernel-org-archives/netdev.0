From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [Intel-wired-lan] [PATCH] e1000: free skb when returning on
 -ENOMEM error
Date: Thu, 22 Oct 2015 18:15:11 +0200
Message-ID: <CAHmME9ri6tm_cnkuYpFNgCp1DQEiwUTcJ8M_FCRX_4b=WNjTmg@mail.gmail.com>
References: <1445527642-15567-1-git-send-email-Jason@zx2c4.com>
	<562907DF.3070404@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	jesse.brandeburg@intel.com, shannon.nelson@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	matthew.vick@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com, intel-wired-lan@lists.osuosl.org,
	Netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:51248 "EHLO frisell.zx2c4.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757002AbbJVQPQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Oct 2015 12:15:16 -0400
In-Reply-To: <562907DF.3070404@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

You're right. Sorry for the noise Please ignore.
