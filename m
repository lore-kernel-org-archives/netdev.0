From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] ath9k: remove cast to void pointer
Date: Thu, 31 Aug 2017 14:29:00 -0700
Message-ID: <1504214940.2786.47.camel@perches.com>
References: <1504184863-9732-1-git-send-email-himanshujha199640@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: ath9k-devel@qca.qualcomm.com, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Himanshu Jha <himanshujha199640@gmail.com>, kvalo@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1504184863-9732-1-git-send-email-himanshujha199640@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-08-31 at 18:37 +0530, Himanshu Jha wrote:
> casting to void pointer from any pointer type and vice-versa is done
> implicitly and therefore casting is not needed in such a case.

You said you were going to remember to mention the tool
and script that did this.
