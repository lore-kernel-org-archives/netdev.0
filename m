From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] switch x25_asy over to initcalls
Date: Fri, 09 May 2003 09:36:48 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030509.093648.59680645.davem@redhat.com>
References: <20030509091219.A1499@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hch@lst.de
In-Reply-To: <20030509091219.A1499@lst.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Christoph Hellwig <hch@lst.de>
   Date: Fri, 9 May 2003 09:12:19 +0200

   I also had to fix the ldisc initialization because it was so ugly
   and the different ioctl + cast mess because I couldn't look at it.
   
Applied, thanks Christoph.
