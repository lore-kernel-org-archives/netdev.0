From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH]: fix no_cong_thresh sysctl
Date: Tue, 22 Jul 2003 23:37:57 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030722233757.1780042d.davem@redhat.com>
References: <3F1D59B4.3080307@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <3F1D59B4.3080307@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 22 Jul 2003 17:35:16 +0200
Patrick McHardy <kaber@trash.net> wrote:

> these two patches fix the net.core.no_cong_thresh sysctl, the value
> accessed is in fact no_cong.

Applied, thanks a lot Patrick.
