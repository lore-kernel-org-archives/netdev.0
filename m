From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] switch lanmedia driver to initcalls
Date: Mon, 26 May 2003 16:33:00 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030526.163300.28812759.davem@redhat.com>
References: <20030526192513.GA5995@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hch@lst.de
In-Reply-To: <20030526192513.GA5995@lst.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Christoph Hellwig <hch@lst.de>
   Date: Mon, 26 May 2003 21:25:13 +0200

   It's a PCI driver and has no business in setup.c :)
   
Applied, thanks :-)
