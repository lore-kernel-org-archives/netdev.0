From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] convert madgemc to initcalls
Date: Fri, 23 May 2003 00:50:26 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030523.005026.54198701.davem@redhat.com>
References: <20030523091858.A28081@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hch@lst.de
In-Reply-To: <20030523091858.A28081@lst.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Christoph Hellwig <hch@lst.de>
   Date: Fri, 23 May 2003 09:18:58 +0200

   This is a MCA driver so there should be no probe order issues.

Applied, thanks.
