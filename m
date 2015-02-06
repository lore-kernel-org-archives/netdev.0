From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: cw1200: use msecs_to_jiffies for conversion
Date: Fri,  6 Feb 2015 06:43:39 +0000 (UTC)
Message-ID: <20150206064339.92EB9140C72@smtp.codeaurora.org>
References: <1423035589-3647-1-git-send-email-hofrat@osadl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Solomon Peachy <pizza@shaftnet.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Nicholas Mc Guire <hofrat@osadl.org>
To: Nicholas Mc Guire <hofrat@osadl.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423035589-3647-1-git-send-email-hofrat@osadl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> This is only an API consolidation to make things more readable.
> Instances of  HZ / CONST  are replaced by appropriate msecs_to_jiffies().
> 
> Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>

Thanks, applied to wireless-drivers-next.git.

Kalle Valo
