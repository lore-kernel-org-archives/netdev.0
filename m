From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Add 32bit emulation for cmsg SO_TIMESTAMP
Date: Wed, 7 Jan 2004 12:12:58 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040107121258.722a7f16.davem@redhat.com>
References: <20040107100743.1c0b18c2.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040107100743.1c0b18c2.ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 7 Jan 2004 10:07:43 +0100
Andi Kleen <ak@suse.de> wrote:

> Some traceroute versions use the SO_TIMESTAMP cmsg for time measurement.
> This fixes them when running as 32bit on a 64bit x86-64 kernel.

Applied, thanks Andi.
