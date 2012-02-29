From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH 0/4] iwlegacy cleanups
Date: Wed, 29 Feb 2012 09:31:47 +0100
Message-ID: <20120229083147.GD2391@redhat.com>
References: <1330367133-26465-1-git-send-email-Gregory.Dietsche@cuw.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Greg Dietsche <Gregory.Dietsche@cuw.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1330367133-26465-1-git-send-email-Gregory.Dietsche@cuw.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 27, 2012 at 12:25:29PM -0600, Greg Dietsche wrote:
> The first two patches reorganize the Kconfig for the iwlegacy drivers. This is
> intended to make the debug options appear in a more logical manner.
> 
> The second two patches remove some unused code from the iwlegacy driver.
> 
> These patches are based on the wireless-next tree.
> 
> Greg Dietsche (4):
>   iwlegacy: Kconfig: Move Debugging Options
>   iwlegacy: Kconfig: Change Debug Option to be more clear
>   iwlegacy: remove enum iw_calib and related code
>   iwlegacy: remove unused enum il4965_calib_enabled_state

ACK for series, thanks Greg.

Stanislaw
