From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] performance problem with established hash
Date: Fri, 27 Feb 2004 23:51:20 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040227235120.72fc185a.davem@redhat.com>
References: <20040228022537.GR5801@krispykreme>
	<20040227195548.210f7204.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: anton@samba.org, netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
        kenneth.w.chen@intel.com, olof@austin.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20040227195548.210f7204.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 27 Feb 2004 19:55:48 -0800
Andrew Morton <akpm@osdl.org> wrote:

> This should fix it up.  We keep the table sizing identical to that which
> we had in 2.6.earlier, with a boot option override.

Andrew, just push this to Linus now if you haven't already :)
