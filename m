From: "David S. Miller" <davem@redhat.com>
Subject: Re: [BK ChangeSet@1.1118.1.1] new module infrastructure for
 net_proto_family
Date: Wed, 23 Apr 2003 20:29:54 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030423.202954.85407627.davem@redhat.com>
References: <5.1.0.14.2.20030423134636.100e5c60@unixmail.qualcomm.com>
	<20030423.163043.41633133.davem@redhat.com>
	<5.1.0.14.2.20030423182014.07ec6140@unixmail.qualcomm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@conectiva.com.br, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: maxk@qualcomm.com
In-Reply-To: <5.1.0.14.2.20030423182014.07ec6140@unixmail.qualcomm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Max Krasnyansky <maxk@qualcomm.com>
   Date: Wed, 23 Apr 2003 18:41:56 -0700

   At 04:30 PM 4/23/2003, David S. Miller wrote:
   >Your stuff was unacceptable from the start because you didn't put
   >the ->owner into the protocol ops.
   But you didn't tell me that. You just said that it's "an ugly hack" without
   giving any other feedback.
    
As you mention, Rusty said this.

   What about this though
   
I'm sure Arnaldo will deal with the sys_accept() issues.
But this is a minor issue, Arnaldo's stuff is architectually
solid.
