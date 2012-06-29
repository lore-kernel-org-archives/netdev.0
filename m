From: David Miller <davem@davemloft.net>
Subject: Re: AF_BUS socket address family
Date: Fri, 29 Jun 2012 15:36:56 -0700 (PDT)
Message-ID: <20120629.153656.1141845894730637434.davem@davemloft.net>
References: <1340988354-26981-1-git-send-email-vincent.sanders@collabora.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: vincent.sanders@collabora.co.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1340988354-26981-1-git-send-email-vincent.sanders@collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


There is no extensive text describing why using IPv4 for this cannot
be done.  I can almost bet that nobody really, honestly, tried.

Basically this means all of our feedback from the last time we had
discussions on kernel IPC for DBUS are being completely ignored.

Therefore, I will completely ignore this patch submission.
