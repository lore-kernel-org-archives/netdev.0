From: Christian Lamparter <chunkeey@googlemail.com>
Subject: Re: [PATCH 16/20] drivers/net/wireless/p54: remove depends on CONFIG_EXPERIMENTAL
Date: Tue, 22 Jan 2013 19:37:16 +0100
Message-ID: <201301221937.16916.chunkeey@googlemail.com>
References: <1358879444-25834-1-git-send-email-keescook@chromium.org> <1358879444-25834-17-git-send-email-keescook@chromium.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Greg Kroah-Hartman" <gregkh@linuxfoundation.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358879444-25834-17-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Aren't these patches going through wireless-next
or linux-next?

On Tuesday, January 22, 2013 07:30:40 PM Kees Cook wrote:
> The CONFIG_EXPERIMENTAL config item has not carried much meaning for a
> while now and is almost always enabled by default. As agreed during the
> Linux kernel summit, remove it from any "depends on" lines in Kconfigs.
> 
> CC: Christian Lamparter <chunkeey@googlemail.com>
> CC: "John W. Linville" <linville@tuxdriver.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: NetDev <netdev@vger.kernel.org>
> Signed-off-by: Kees Cook <keescook@chromium.org>
Acked-by: Christian Lamparter <chunkeey@googlemail.com>
[Also ACK the carl9170, if necessary]

Regards,
	Chr
