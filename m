From: "David S. Miller" <davem@redhat.com>
Subject: Re: IPv6/sparc64: icmp port unreachable corruption
Date: Wed, 12 Nov 2003 14:40:54 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031112144054.2b65feb9.davem@redhat.com>
References: <20031109122844.GA14241@wsx.ksp.sk>
	<20031110214603.0057e365.davem@redhat.com>
	<20031111222611.GA1239@wsx.ksp.sk>
	<20031111151340.3d129bc7.davem@redhat.com>
	<20031112012641.00018cb8.davem@redhat.com>
	<20031112151444.GA9727@wsx.ksp.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jan Oravec <jan.oravec@6com.sk>
In-Reply-To: <20031112151444.GA9727@wsx.ksp.sk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 12 Nov 2003 16:14:44 +0100
Jan Oravec <jan.oravec@6com.sk> wrote:

> You have forgot to decrease 'len' by msg.offset here:

Indeed, thanks a lot for all of your help Jan.
