From: nick <xerofoify@gmail.com>
Subject: Question about FIXME in the function,ath10k_htc_send_complete_check
 for the file htc.c
Date: Sun, 25 Jan 2015 01:32:33 -0500
Message-ID: <54C48E01.8020105@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
 linux-kernel@vger.kernel.org, ath10k@lists.infradead.org
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

Greetings Again Kalle and others,
I am wondering about the fix me in the function,ath10k_htc_send_complete_check
for the file,htc.c. I am wondering if there is a hardware limitation and the
line for reserving 20 bytes for the sk_buff used is need in this function. I
am assuming this is needed due to hardware limitations and therefore can't be
removed but should be commented explaining this limitation. Please let me known
otherwise if I am missing something.
Thanks,
Nick 
