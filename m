From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] fix HIPQUAD macro in kernel.h
Date: Thu, 08 Aug 2002 07:58:16 -0700 (PDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020808.075816.56749431.davem@redhat.com>
References: <20020808133112.E11828@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <owner-netdev@oss.sgi.com>
To: laforge@gnumonks.org
In-Reply-To: <20020808133112.E11828@sunbeam.de.gnumonks.org>
List-Id: netdev.vger.kernel.org

   From: Harald Welte <laforge@gnumonks.org>
   Date: Thu, 8 Aug 2002 13:31:12 +0200

   Below is a fix for the HIPQUAD macro in kernel.h.  The macro is currently
   not endian-aware - it just assumes running on a little-endian machine.
   
This looks fine, I've added it to both my 2.4.x and 2.5.x
networking trees.

Thanks.
