From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/1] connector: Added coredumping event to the
 process connector
Date: Wed, 20 Mar 2013 13:24:34 -0400 (EDT)
Message-ID: <20130320.132434.1915240905937319723.davem@davemloft.net>
References: <1363762205-26206-1-git-send-email-jderehag@hotmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zbr@ioremap.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jderehag@hotmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1363762205-26206-1-git-send-email-jderehag@hotmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Derehag <jderehag@hotmail.com>
Date: Wed, 20 Mar 2013 07:50:05 +0100

> Process connector can now also detect coredumping events.
> Main aim of patch is get notified at start of coredumping, instead of having to wait for it to finish and then being notified through EXIT event.
> Could be used for instance by process-managers that want to get notified as soon as possible about process failures, and not necessarily beeing notified after coredump, which could be in the order of minutes depending on size of coredump, piping and so on.
> 
> Signed-off-by: Jesper Derehag <jderehag@hotmail.com>

Applied, thanks.
