From: "David S. Miller" <davem@redhat.com>
Subject: Re: comment about struct tcp_tw_bucket in struct sock
Date: Wed, 14 May 2003 12:18:06 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030514.121806.41651014.davem@redhat.com>
References: <20030513210541.GA4415@suse.de>
	<20030513.163150.28800008.davem@redhat.com>
	<20030514083236.GD8290@Wotan.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: olh@suse.de, marcelo@conectiva.com.br, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ak@suse.de
In-Reply-To: <20030514083236.GD8290@Wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Andi Kleen <ak@suse.de>
   Date: Wed, 14 May 2003 10:32:36 +0200

   On Tue, May 13, 2003 at 04:31:50PM -0700, David S. Miller wrote:
   > It's documented in tcp.h already.
   
   Just not everybody changing sock.h also reads tcp.h :-(

You assume that protocols in the tree are the only thing
that might break if you edit struct sock.
