From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] 2/3 rtnetlink -- RTA_PUT unlikely.
Date: Tue, 23 Sep 2003 04:01:00 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030923040100.5d44db47.davem@redhat.com>
References: <20030922163639.6d7ac30f.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030922163639.6d7ac30f.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 22 Sep 2003 16:36:39 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> RTA_PUT should normally be handed enough space, so optimize 

Applied.
