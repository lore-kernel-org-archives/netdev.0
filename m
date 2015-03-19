From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH] mac802154: fix typo in header guard
Date: Thu, 19 Mar 2015 14:46:26 +0100
Message-ID: <1426772786.23529.4.camel@x220>
References: <1426771420-29979-1-git-send-email-nicolas.iooss_linux@m4x.org>
	 <20150319133724.GA14436@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Nicolas Iooss <nicolas.iooss_linux@m4x.org>,
	linux-wpan@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, marcel@holtmann.org
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150319133724.GA14436@omega>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-03-19 at 14:37 +0100, Alexander Aring wrote:
> On Thu, Mar 19, 2015 at 09:23:40PM +0800, Nicolas Iooss wrote:
> > Signed-off-by: Nicolas Iooss <nicolas.iooss_linux@m4x.org>
> > Fixes: b6eea9ca354a ("mac802154: introduce driver-ops header")
> 
> Acked-by: Alexander Aring <alex.aring@gmail.com>
> 
> can you please queue this into bluetooth-next or even bluetooth?

Is the Fixes: tag needed?

mac802154.ko builds fine on my machine. There's also no error or warning
included in the commit explanation. So it seems this is just a typo fix,
not something that should be sent to stable too. Or did I miss something
non-obvious?


Paul Bolle
