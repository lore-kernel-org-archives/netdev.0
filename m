From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] gianfar: do not advertise any alarm capability.
Date: Thu, 25 Apr 2013 01:46:23 -0400 (EDT)
Message-ID: <20130425.014623.160664215002631231.davem@davemloft.net>
References: <16ea6333aec82761aa7e2207b53cfbad85e9245b.1366695641.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@vger.kernel.org
To: richardcochran@gmail.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <16ea6333aec82761aa7e2207b53cfbad85e9245b.1366695641.git.richardcochran@gmail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Richard Cochran <richardcochran@gmail.com>
Date: Tue, 23 Apr 2013 07:42:16 +0200

> An early draft of the PHC patch series included an alarm in the
> gianfar driver. During the review process, the alarm code was dropped,
> but the capability removal was overlooked. This patch fixes the issue
> by advertising zero alarms.
> 
> This patch should be applied to every 3.x stable kernel.
> 
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>
> Reported-by: Chris LaRocque <clarocq@gmail.com>
> Cc: <stable@vger.kernel.org>

Applied.
