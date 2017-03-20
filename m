From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: ath10k: remove redundant check of len with buf_len
Date: Mon, 20 Mar 2017 16:25:19 +0100
Message-ID: <a669166e00c5481e880f6cfbb28fea7f@euamsexm01a.eu.qualcomm.com>
References: <20170315163641.17052-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
 linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
 ath10k@lists.infradead.org
To: Colin Ian King <colin.king@canonical.com>
Return-path: <ath10k-bounces+gldad-ath10k=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170315163641.17052-1-colin.king@canonical.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/ath10k>,
 <mailto:ath10k-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/ath10k/>
List-Post: <mailto:ath10k@lists.infradead.org>
List-Help: <mailto:ath10k-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/ath10k>,
 <mailto:ath10k-request@lists.infradead.org?subject=subscribe>
Sender: "ath10k" <ath10k-bounces@lists.infradead.org>
Errors-To: ath10k-bounces+gldad-ath10k=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Colin Ian King <colin.king@canonical.com> wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> The check of len > buf_len is redundant as len is initialized
> to 0 and buf_len to 4096, so this comparison is always false.
> Remove it.
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Patch applied to ath-next branch of ath.git, thanks.

eed4721fb617 ath10k: remove redundant check of len with buf_len

-- 
https://patchwork.kernel.org/patch/9626131/

Documentation about submitting wireless patches and checking status
from patchwork:

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
