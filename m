From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] net/core/sock.c - 2.4.18
Date: Tue, 21 May 2002 00:45:24 -0700 (PDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <accuqa$j30$2@main.gmane.org>
References: <Pine.LNX.4.44.0205201738180.19839-100000@nacho.alt.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
   linux-net@vger.kernel.org
Return-path: <owner-netdev@oss.sgi.com>
To: ccaputo@alt.net
In-Reply-To: <Pine.LNX.4.44.0205201738180.19839-100000@nacho.alt.net>
List-Id: netdev.vger.kernel.org

   From: Chris Caputo <ccaputo@alt.net>
   Date: Mon, 20 May 2002 17:44:10 -0700 (PDT)

   This patch corrects a typo in net/core/sock.c.  The assignment to
   sysctl_wmem_default was done twice in a row, rather than to
   sysctl_wmem_default and sysctl_rmem_default.
   
   This patch applies to 2.4.18.
   
Thanks, I've applied your patch.
