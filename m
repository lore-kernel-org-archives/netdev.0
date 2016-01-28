From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] ath9k: Drop useless const on
	chanctx_event_delta() return type
Date: Thu, 28 Jan 2016 10:24:14 +0200
Message-ID: <87fuxim7rl.fsf@kamboji.qca.qualcomm.com>
References: <1452865290-32314-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ath9k-devel@lists.ath9k.org,
	linux-wireless@vger.kernel.org,
	QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
	linux-kernel@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <ath9k-devel-bounces@lists.ath9k.org>
In-Reply-To: <1452865290-32314-1-git-send-email-geert@linux-m68k.org> (Geert
	Uytterhoeven's message of "Fri, 15 Jan 2016 14:41:30 +0100")
List-Unsubscribe: <https://lists.ath9k.org/mailman/listinfo/ath9k-devel>,
	<mailto:ath9k-devel-request@lists.ath9k.org?subject=unsubscribe>
List-Archive: <http://lists.ath9k.org/pipermail/ath9k-devel>
List-Post: <mailto:ath9k-devel@lists.ath9k.org>
List-Help: <mailto:ath9k-devel-request@lists.ath9k.org?subject=help>
List-Subscribe: <https://lists.ath9k.org/mailman/listinfo/ath9k-devel>,
	<mailto:ath9k-devel-request@lists.ath9k.org?subject=subscribe>
Sender: ath9k-devel-bounces@lists.ath9k.org
Errors-To: ath9k-devel-bounces@lists.ath9k.org
List-Id: netdev.vger.kernel.org

Geert Uytterhoeven <geert@linux-m68k.org> writes:

> drivers/net/wireless/ath/ath9k/channel.c:230: warning: type qualifiers ignored on function return type
>
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>

Applied to ath.git, thanks.

-- 
Kalle Valo
