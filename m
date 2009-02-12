From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [patch 2/2] bluetooth: CONFIG_DEBUG_LOCK_ALLOC ifdefs remove
Date: Thu, 12 Feb 2009 02:52:38 +0100
Message-ID: <1234403558.7293.28.camel@violet>
References: <200902112128.n1BLSCdw000376@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200902112128.n1BLSCdw000376-AB4EexQrvXRQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

> Due to lockdep changes the CONFIG_DEBUG_LOCK_ALLOC ifdef is not needed
> now, just remove it here.
> 
> The following commit fixed the !lockdep build warnings:

already part of my bluetooth-testing.git tree.

Regards

Marcel
