From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: fsl: fec: handle 10Mbps speed in RMII mode
Date: Thu, 12 Jan 2012 20:05:56 -0800 (PST)
Message-ID: <20120112.200556.1749523544894504540.davem@davemloft.net>
References: <1326384628-7967-1-git-send-email-eric@eukrea.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, shawn.guo@linaro.org,
 linux-arm-kernel@lists.infradead.org, u.kleine-koenig@pengutronix.de
To: eric@eukrea.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1326384628-7967-1-git-send-email-eric@eukrea.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Eric B=E9nard <eric@eukrea.com>
Date: Thu, 12 Jan 2012 17:10:28 +0100

> when the link is 10 Mbps and the mode is RMII, it's necessary
> to set FRCONT to 1 in MIIGSK_CFGR to divide the RMII source
> clock by 10 in order to support 10 Mbps operations.
> =

> Signed-off-by: Eric B=E9nard <eric@eukrea.com>
> Acked-by: Shawn Guo <shawn.guo@linaro.org>

Applied.
