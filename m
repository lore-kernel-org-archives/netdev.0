From: Joe Perches <joe@perches.com>
Subject: [PATCH] MAINTAINERS: USB, remove F: drivers/net/usb/ pattern
Date: Tue, 30 Jul 2013 08:17:59 -0700
Message-ID: <1375197479.2075.116.camel@joe-AO722>
References: <D7C722C73C7A400780358D0376412267@realtek.com.tw>
	 <1375172936-4145-1-git-send-email-hayeswang@realtek.com>
	 <20130730135828.GD27962@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Hayes Wang <hayeswang@realtek.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	nic_swsd@realtek.com
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130730135828.GD27962@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-07-30 at 06:58 -0700, Greg KH wrote:

> In the future, you do not need to send drivers/net/usb/ patches to me,
> netdev and the linux-usb mailing lists should be sufficient.

Signed-off-by: Joe Perches <joe@perches.com>
---

This might help...

diff --git a/MAINTAINERS b/MAINTAINERS
index 339e798..9b5335a 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -8780,7 +8780,6 @@ W:	http://www.linux-usb.org
 T:	git git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/usb.git
 S:	Supported
 F:	Documentation/usb/
-F:	drivers/net/usb/
 F:	drivers/usb/
 F:	include/linux/usb.h
 F:	include/linux/usb/
