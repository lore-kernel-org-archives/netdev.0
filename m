From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Too late check in af_packet.c
Date: Tue, 7 Sep 2004 13:40:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040907134008.28c55c87.davem@davemloft.net>
References: <20040903205206.GT26419@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Dave Jones <davej@redhat.com>
In-Reply-To: <20040903205206.GT26419@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 3 Sep 2004 21:52:06 +0100
Dave Jones <davej@redhat.com> wrote:

> Using the automated source checker at coverity.com, they picked up
> on some code in packet_release() where a NULL check was done
> after dereferencing.  Patch below.
> 
> Signed-off-by: Dave Jones <davej@redhat.com>

Looks great, applied.

Thanks.
