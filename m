From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] bna: remove obsolete use of EXTRA_CFLAGS
Date: Wed, 10 Jun 2015 21:59:12 -0700 (PDT)
Message-ID: <20150610.215912.592540288315859289.davem@davemloft.net>
References: <1433852683-1938-1-git-send-email-jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rasesh.mody@qlogic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jslaby@suse.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1433852683-1938-1-git-send-email-jslaby@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Slaby <jslaby@suse.cz>
Date: Tue,  9 Jun 2015 14:24:43 +0200

> EXTRA_CFLAGS should be used on the command line only.
> 
> Since EXTRA_CFLAGS here add only a non-existant path to compiler
> include paths (by -I), remove EXTRA_CFLAGS completely.
> 
> Signed-off-by: Jiri Slaby <jslaby@suse.cz>

Applied to net-next, thanks.
