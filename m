From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] skb_pull add unlikely
Date: Thu, 7 Aug 2003 14:29:15 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030807142915.64081139.davem@redhat.com>
References: <20030807142151.376e5b3c.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030807142151.376e5b3c.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 7 Aug 2003 14:21:51 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Yet another case where giving compiler hints may speed up packet fast path.

Applied, thanks Stephen.
