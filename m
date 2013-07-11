From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] alx: fix lockdep annotation
Date: Thu, 11 Jul 2013 11:47:49 -0700 (PDT)
Message-ID: <20130711.114749.1349623560206444581.davem@davemloft.net>
References: <51DEB8D1.6080700@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jcliburn@gmail.com, chris.snook@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: maarten.lankhorst@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51DEB8D1.6080700@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Maarten Lankhorst <maarten.lankhorst@canonical.com>
Date: Thu, 11 Jul 2013 15:53:21 +0200

> Move spin_lock_init to be called before the spinlocks are used, preventing a lockdep splat.
> 
> Signed-off-by: Maarten Lankhorst <maarten.lankhorst@canonical.com>

Looks good, applied, thanks.
