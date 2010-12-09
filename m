From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 0/7] e1000e: cleanup
Date: Wed, 8 Dec 2010 19:37:20 -0800
Message-ID: <20101208193720.5e137627@nehalam>
References: <1291862457-16671-1-git-send-email-asbjorn@asbjorn.biz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Asbjoern Sloth Toennesen <asbjorn@asbjorn.biz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1291862457-16671-1-git-send-email-asbjorn@asbjorn.biz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu,  9 Dec 2010 02:40:50 +0000
Asbjoern Sloth Toennesen <asbjorn@asbjorn.biz> wrote:

> Hi,
> 
> This patchset fixes most checkstyle problems in e1000e.
> 
> Checkpatch summary:
> pre:	total:	221 errors,	129 warnings,	24520 lines checked
> post:	total:	2 errors,	34 warnings,	24533 lines checked

IMHO these patches are in the why bother category, they deal only
with whitespace and things that checkpatch is too stupid to understand.

Checkpatch is a rough saw only appropriate to doing initial cutting
through crap drivers.
