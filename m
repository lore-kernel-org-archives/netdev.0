From: "David S. Miller" <davem@redhat.com>
Subject: Re: sysctl variable to force MLD version [PATCH]
Date: Mon, 16 Feb 2004 22:52:51 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040216225251.00a44597.davem@redhat.com>
References: <m3wu6p6c3f.wl@sfc.wide.ad.jp>
	<OF2AD6D710.B1604DA1-ON88256E3D.001C2A6D-88256E3D.001C8122@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: sekiya@wide.ad.jp, hibi665@oki.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OF2AD6D710.B1604DA1-ON88256E3D.001C2A6D-88256E3D.001C8122@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 16 Feb 2004 22:14:09 -0700
David Stevens <dlstevens@us.ibm.com> wrote:

>       Below is a patch for 2.6.2 that adds a sysctl variable
> to force the MLD version to version 1, for MLD-snooping switches
> that don't understand version 2 packet formats.

Queued up for 2.6.4, thanks David.
