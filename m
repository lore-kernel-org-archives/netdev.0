From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] mark init_etherdev as deprecated
Date: Thu, 16 Oct 2003 16:31:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031016163133.47987b85.davem@redhat.com>
References: <20031016102831.589d9e20.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20031016102831.589d9e20.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 16 Oct 2003 10:28:31 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> For 2.6.0-test7-bk latest, mark init_etherdev as deprecated because it is
> implicitly racy, and has been replaced by using alloc_etherdev.

Applied, thanks Stephen.
