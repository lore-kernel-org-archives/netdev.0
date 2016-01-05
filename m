From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: rsi: Delete unnecessary variable initialisations in
 rsi_send_mgmt_pkt()
Date: Tue, 5 Jan 2016 09:29:58 +0100
Message-ID: <568B7F06.1010500@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
 <5687E169.4070704@users.sourceforge.net>
 <5687E203.1070404@users.sourceforge.net> <20160104092857.GD5284@mwanda>
 <568A4CFF.8060600@users.sourceforge.net> <20160104114849.GH5284@mwanda>
 <568A668D.8090007@users.sourceforge.net>
 <CAGRGNgXw+G6ZcmFmM=VWZT_jibuZyxe-kSvPSF8W7hPueLhNrw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
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
In-Reply-To: <CAGRGNgXw+G6ZcmFmM=VWZT_jibuZyxe-kSvPSF8W7hPueLhNrw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> That said, if you figure out some change that produces significant
> reductions in code or binary size on multiple architectures without
> making things more complicated, less readable or making the code or
> binary size larger, then by all means propose it.

Are you looking also for "a proof" that such changes are worthwhile?


> "This makes things smaller" carries much more weight than
> "I think this is better".

Can the discussed implementation of a function like "rsi_send_mgmt_pkt"
become a bit smaller by the deletion of extra variable initialisations


> Almost all of the changes you've proposed that have seen any
> discussion whatsoever fall into the latter category.

Thanks for your interesting feedback.

Can a further constructive dialogue evolve from the presented information?

Regards,
Markus
