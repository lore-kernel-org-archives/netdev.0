From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [1/3] ath10k: remove multiple defines of DIAG_TRANSFER_LIMIT
Date: Fri, 27 Jan 2017 10:04:54 -0800
Message-ID: <10e75338551b4824b607cd630521b2f0@eusanexr01a.eu.qualcomm.com>
References: <1485183876-27080-1-git-send-email-srinivas.kandagatla@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
 Srinivas Kandagatla <srinivas.kandagatla@linaro.org>,
 linux-kernel@vger.kernel.org, ath10k@lists.infradead.org
To: Srinivas Kandagatla <srinivas.kandagatla@linaro.org>
Return-path: <ath10k-bounces+gldad-ath10k=m.gmane.org@lists.infradead.org>
In-Reply-To: <1485183876-27080-1-git-send-email-srinivas.kandagatla@linaro.org>
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

Srinivas Kandagatla <srinivas.kandagatla@linaro.org> wrote:
> DIAG_TRANSFER_LIMIT is redefined with same value and comments
> just below this entry, remove this duplicate entry.
> 
> Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@linaro.org>

3 patches applied to ath-next branch of ath.git, thanks.

dd51fa3d8a1d ath10k: remove multiple defines of DIAG_TRANSFER_LIMIT
0de4df5ba2ad ath10k: use dma_zalloc_coherent()
1ad38fd719da ath10k: fix typo in addr calculation

-- 
https://patchwork.kernel.org/patch/9532691/

Documentation about submitting wireless patches and checking status
from patchwork:

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
