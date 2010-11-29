From: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Subject: Re: [PATCH wireless-next] ath: Rename ath_print to ath_debug
Date: Sun, 28 Nov 2010 18:17:33 -0800
Message-ID: <AANLkTinc251WbwuLqFbOZ5ipNGZW7=wub3DoWwy42=+e@mail.gmail.com>
References: <5febb0e1fba0ec2bb77f6ade8b251ba0edf4614c.1290988277.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jouni Malinen <jmalinen@atheros.com>,
	Vasanthakumar Thiagarajan <vasanth@atheros.com>,
	Senthil Balasubramanian <senthilkumar@atheros.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, ath9k-devel@lists.ath9k.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5febb0e1fba0ec2bb77f6ade8b251ba0edf4614c.1290988277.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 28, 2010 at 3:53 PM, Joe Perches <joe@perches.com> wrote:
> Make the function name match the function purpose.
> ath_debug is a debug only facility.
> ath_print seems too generic a name for a debug only use.
>
> Removed an unnecessary trailing space in htc_drv_main.c
>
> Signed-off-by: Joe Perches <joe@perches.com>

Nack, I don't see the point.

  Luis
