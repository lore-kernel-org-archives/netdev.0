From: Lee Revell <rlrevell@joe-job.com>
Subject: Re: [RFC: 2.6 patch] CONFIG_FORCEDETH updates
Date: Sun, 12 Feb 2006 17:03:36 -0500
Message-ID: <1139781817.19342.300.camel@mindpipe>
References: <20060212175202.GK30922@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751476AbWBLWDn@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20060212175202.GK30922@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2006-02-12 at 18:52 +0100, Adrian Bunk wrote:
> This patch contains the following possible updates:
> - let FORCEDETH no longer depend on EXPERIMENTAL
> - remove the "Reverse Engineered" from the option text:
>   for the user it's important which hardware the driver supports, not
>   how it was developed

Is this driver as stable as one that was developed with proper
documentation?  I prefer to know that something as elementary as a fast
ethernet controller had to be reverse engineered so I can avoid
supporting a vendor so hostile to Linux.

Lee
