From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: [PATCH 1/3] rsi: Delete unnecessary variable initialisations in
 rsi_send_mgmt_pkt()
Date: Mon, 4 Jan 2016 11:44:15 +0100
Message-ID: <568A4CFF.8060600@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
 <5687E169.4070704@users.sourceforge.net>
 <5687E203.1070404@users.sourceforge.net> <20160104092857.GD5284@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Kalle Valo <kvalo@codeaurora.org>,
	LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160104092857.GD5284@mwanda>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> These patches are labour intensive to review because you can't just do
> it in the email client.

Thanks for your general interest.


> Also you were not able to review it properly yourself and introduced
> a bug.

I admit that it can happen during my software development that I overlook
implementation details somehow.


> I am often remove initializers but it's normally because I am changing
> something else which makes it worthwhile.

It is nice to hear that you are also occasionally looking for similar
update candidates.


> This patch is the correct thing but it's not "worthwhile".

I find this view interesting.


> Please stop sending cleanup patches, Markus.  Just send fixes.

How often will source code clean-up fix something?


May I resend a consistent patch series for the source file
"drivers/net/wireless/rsi/rsi_91x_pkt.c" in the near future?

Regards,
Markus
