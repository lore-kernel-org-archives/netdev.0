From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH V2 net-next 2/3] bnx2x: Coalesce pr_cont uses and
 fix DP typos
Date: Wed, 17 Aug 2011 16:42:25 +0300
Message-ID: <1313588545.7266.8.camel@lb-tlvb-eilong.il.broadcom.com>
References: <cover.1313360100.git.joe@perches.com>
 <88e0b7cd0aa9fdb34acae665d8bc235f8aa33ddf.1313360100.git.joe@perches.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Joe Perches" <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <88e0b7cd0aa9fdb34acae665d8bc235f8aa33ddf.1313360100.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2011-08-14 at 15:16 -0700, Joe Perches wrote:
> Uses of pr_cont should be avoided where reasonably possible
> because they can be interleaved by other threads and processes.
> 
> Coalesce pr_cont uses.
> 
> Fix typos, duplicated words and spacing in DP uses caused
> by split multi-line formats.  Coalesce some of these
> split formats.  Add missing terminating newlines to DP uses.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
Acked-by: Eilon Greenstein <eilong@broadcom.com>
