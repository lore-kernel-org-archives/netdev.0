From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: rsi: Delete unnecessary variable initialisations in
 rsi_send_mgmt_pkt()
Date: Tue, 5 Jan 2016 17:23:04 +0100
Message-ID: <568BEDE8.4010203@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
 <5687E169.4070704@users.sourceforge.net>
 <5687E203.1070404@users.sourceforge.net> <20160104092857.GD5284@mwanda>
 <568A4CFF.8060600@users.sourceforge.net> <20160104114849.GH5284@mwanda>
 <568A668D.8090007@users.sourceforge.net>
 <CAGRGNgXw+G6ZcmFmM=VWZT_jibuZyxe-kSvPSF8W7hPueLhNrw@mail.gmail.com>
 <568B7F06.1010500@users.sourceforge.net>
 <CAGRGNgVVnFGt_mHV+ZrZW0HuGuuh++ohkkNMHPBFt73-+X3L8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Dan Carpenter <dan.carpenter@oracle.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Kalle Valo <kvalo@codeaurora.org>,
	LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: Julian Calaby <julian.calaby@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGRGNgVVnFGt_mHV+ZrZW0HuGuuh++ohkkNMHPBFt73-+X3L8Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Every time you send a set of patches,

I suggested some updates for Linux source files since October 2014.


> there are legitimate issues which people raise,

There was usual feedback.


> and every time they are discussed,

The discussion results were mixed between acceptance
and usual disagreement.


> you assert that your patches improve things

I guess that should be the default intention of every patch, shouldn't it?


> and seem to ignore the concerns people raise.

I hope not. - But I can imagine that you might understand some responses
from contributors in this way.
Are you waiting for another clarification on a specific issue?


> I've seen this same pattern of discussion here with these patches,
> with your patches to move labels into if statements, with the patches
> you sent late June last year, your patches to remove conditions before
> kfree() and friends, etc.

It seems that communication difficulties come partly from the fact
that I chose search patterns from static source code analysis so far
which belong to an error category that gets a lower priority.


> You need to change you attitude: just because you can see some benefit
> from your patches doesn't mean others do and it doesn't mean that
> they're willing to accept them.

I understand your advice.

Further update suggestions with higher importance might follow for various
software areas in the future.

Regards,
Markus
