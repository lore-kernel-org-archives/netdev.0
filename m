From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] ath9k: remove duplicate assignment of
	variable ah
Date: Tue, 19 Apr 2016 19:14:18 +0300
Message-ID: <87ega1inj9.fsf@kamboji.qca.qualcomm.com>
References: <1460287531-17385-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ath9k-devel@lists.ath9k.org,
	linux-wireless@vger.kernel.org,
	QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
	linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <ath9k-devel-bounces@lists.ath9k.org>
In-Reply-To: <1460287531-17385-1-git-send-email-colin.king@canonical.com>
	(Colin King's message of "Sun, 10 Apr 2016 12:25:31 +0100")
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

Colin King <colin.king@canonical.com> writes:

> From: Colin Ian King <colin.king@canonical.com>
>
> ah is written twice with the same value, remove one of the
> redundant assignments to ah.
>
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied, thanks.

-- 
Kalle Valo
