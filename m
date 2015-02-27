From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: libertas: remove unnecessary check before calling debugfs_remove
Date: Fri, 27 Feb 2015 08:07:20 +0000 (UTC)
Message-ID: <20150227080720.BA59C13FA62@smtp.codeaurora.org>
References: <1423643586-11002-1-git-send-email-baspeters93@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Bas Peters <baspeters93@gmail.com>, linville@tuxdriver.com,
	johannes.berg@intel.com, dcbw@redhat.com,
	libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Bas Peters <baspeters93@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423643586-11002-1-git-send-email-baspeters93@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Debugfs_remove will check for error or NULL for us, so it is not
> necessary to do this here.
> 
> Signed-off-by: Bas Peters <baspeters93@gmail.com>

Thanks, applied to wireless-drivers-next.git.

Kalle Valo
