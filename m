From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net/ipv4/ipconfig: Rejoin broken lines in console output
Date: Tue, 24 Nov 2015 09:40:55 -0800
Message-ID: <1448386855.20113.8.camel@perches.com>
References: <1448370503-16424-1-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Geert Uytterhoeven <geert+renesas@glider.be>,
	"David S. Miller" <davem@davemloft.net>,
	Bastian Stender <bst@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448370503-16424-1-git-send-email-geert+renesas@glider.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-11-24 at 14:08 +0100, Geert Uytterhoeven wrote:
> Commit 09605cc12c078306 ("net ipv4: use preferred log methods") replaced
> a few calls of pr_cont() after a console print without a trailing
> newline by pr_info(), causing lines to be split during IP
> autoconfiguration


Thanks Geert.
