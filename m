From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 4/7] e1000e: cleanup: fix long lines
Date: Thu, 09 Dec 2010 03:34:23 +0000
Message-ID: <1291865663.19763.2.camel@localhost>
References: <1291862457-16671-1-git-send-email-asbjorn@asbjorn.biz>
	 <1291862457-16671-5-git-send-email-asbjorn@asbjorn.biz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Asbjoern Sloth Toennesen <asbjorn@asbjorn.biz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1291862457-16671-5-git-send-email-asbjorn@asbjorn.biz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-12-09 at 02:40 +0000, Asbjoern Sloth Toennesen wrote:
> This patch breaks long lines, so they do not exceed 80 characters.
> 
> Fixes 2 errors and 26 warnings reported by checkpatch.
[...]

80-character lines are not a strict requirement.  The kernel coding
style is about readability, not slavishingly following rules.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
