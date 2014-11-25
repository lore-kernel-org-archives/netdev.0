From: nick <xerofoify@gmail.com>
Subject: Fix Me in htc.c
Date: Mon, 24 Nov 2014 21:45:55 -0500
Message-ID: <5473ED63.8070601@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
 linville@tuxdriver.com, ath10k@lists.infradead.org,
 linux-kernel@vger.kernel.org
To: kvalo@qca.qualcomm.com
Return-path: <ath10k-bounces+gldad-ath10k=m.gmane.org@lists.infradead.org>
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

Greetings Kalle and John,
I am wondering about what amount we need to reserve for amount of bytes needed for the function, ath10k_htc_build_tx_ctrl_skb in htc.c If one of you can send me the amount of bytes we need to 
reserve for this to function correctly, I will gladly write a patch for this :).
Nick
