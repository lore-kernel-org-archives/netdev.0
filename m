From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Quiet noisy LSM denial when accessing net sysctl
Date: Sun, 08 May 2016 23:56:20 -0400 (EDT)
Message-ID: <20160508.235620.333454221783238471.davem@davemloft.net>
References: <1462575854-4301-1-git-send-email-tyhicks@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, serge.hallyn@canonical.com
To: tyhicks@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462575854-4301-1-git-send-email-tyhicks@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tyler Hicks <tyhicks@canonical.com>
Date: Fri,  6 May 2016 18:04:12 -0500

> This pair of patches does away with what I believe is a useless denial
> audit message when a privileged process initially accesses a net sysctl.

The LSM folks can apply this if they agree with you.
