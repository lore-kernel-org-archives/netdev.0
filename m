From: "David S. Miller" <davem@redhat.com>
Subject: Re: comment about struct tcp_tw_bucket in struct sock
Date: Tue, 13 May 2003 16:31:50 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030513.163150.28800008.davem@redhat.com>
References: <20030513210541.GA4415@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marcelo@conectiva.com.br, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: olh@suse.de
In-Reply-To: <20030513210541.GA4415@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Olaf Hering <olh@suse.de>
   Date: Tue, 13 May 2003 23:05:41 +0200

   we just hit this one. struct tcp_tw_bucket and stuct sock must match.
   
   Please apply.

It's documented in tcp.h already.
