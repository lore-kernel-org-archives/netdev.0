From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] convert /proc/net/dev_mcast to seq_file
Date: Tue, 13 Jan 2004 16:19:58 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040113161958.5e05c655.davem@redhat.com>
References: <20040112135033.3b08f0e9.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040112135033.3b08f0e9.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 12 Jan 2004 13:50:33 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> Convert /proc/net/dev_mcast for 2.6 so it will work with large number of interfaces.

Applied, thanks Stephen.
