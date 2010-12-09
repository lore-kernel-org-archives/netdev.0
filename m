From: Joe Perches <joe@perches.com>
Subject: Re: [trivial PATCH 00/15] remove duplicate unlikely from IS_ERR
Date: Thu, 09 Dec 2010 12:32:53 -0800
Message-ID: <1291926773.20677.26.camel@Joe-Laptop>
References: <1291906801-1389-2-git-send-email-tklauser@distanz.ch>
	 <cover.1291923888.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: uclinux-dist-devel@blackfin.uclinux.org, rtc-linux@googlegroups.com,
 linux-s390@vger.kernel.org, osd-dev@open-osd.org,
 linux-arm-msm@vger.kernel.org,  linux-usb@vger.kernel.org,
 linux-ext4@vger.kernel.org, linux-nfs@vger.kernel.org,  linux-mm@kvack.org,
 Jiri Kosina <trivial@kernel.org>,  dri-devel@lists.freedesktop.org,
 linux-kernel@vger.kernel.org,  linux-scsi@vger.kernel.org,
 linux-wireless@vger.kernel.org,  devel@driverdev.osuosl.org
To: netdev@vger.kernel.org, Tobias Klauser <tklauser@distanz.ch>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <cover.1291923888.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-12-09 at 12:03 -0800, Joe Perches wrote:
> Tobias Klauser <tklauser@distanz.ch> sent a patch to remove
> an unnecessary unlikely from drivers/misc/c2port/core.c,
> https://lkml.org/lkml/2010/12/9/199

It seems that Tobias did send all the appropriate patches,
not as a series, but as individual patches to kernel-janitor.

c2port was the only one that went to lkml.

Please ignore this series and apply Tobias' patches.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
