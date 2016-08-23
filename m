From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: checkpatch: See if modified files are marked obsolete in
 MAINTAINERS
Date: Tue, 23 Aug 2016 09:26:51 +0200
Message-ID: <d5365370-37b5-b367-ba9e-45f4e27f975a@users.sourceforge.net>
References: <87shtwvm63.fsf@kamboji.qca.qualcomm.com>
 <7ceaa510dc9d2df05ec4b456baed7bb1415550b3.1471889575.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Kalle Valo <kvalo@codeaurora.org>,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        Andy Whitcroft <apw@canonical.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        Jouni Malinen <j@w1.fi>, kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>,
        linux-kernel@vger.kernel.org, Fengguang Wu <fengguang.wu@intel.com>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7ceaa510dc9d2df05ec4b456baed7bb1415550b3.1471889575.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Use get_maintainer to check the status of individual files.
> If "obsolete", suggest leaving the files alone.

Will another software system like the "kbuild test robot"
need any more fine-tuning for this change?

Regards,
Markus
